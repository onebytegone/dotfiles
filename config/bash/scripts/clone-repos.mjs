#!/usr/bin/env node

import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';

function usage() {
   console.error('Usage: clone-repos <host>/<scope> [token]');
   console.error('  e.g. clone-repos github.com/onebytegone "$(pbpaste)"');
   process.exit(2);
}

function parseTarget(arg) {
   const withoutScheme = arg.replace(/^https?:\/\//, '').replace(/\/$/, ''),
         slash = withoutScheme.indexOf('/');

   if (slash === -1) {
      usage();
   }

   const host = withoutScheme.slice(0, slash),
         scope = withoutScheme.slice(slash + 1);

   if (!host || !scope) {
      usage();
   }

   return { host, scope };
}

function nextLink(linkHeader) {
   if (!linkHeader) {
      return null;
   }

   for (const part of linkHeader.split(',')) {
      const match = part.match(/<([^>]+)>;\s*rel="next"/);

      if (match) {
         return match[1];
      }
   }

   return null;
}

async function fetchAllPages(startUrl, headers) {
   const items = [];

   let url = startUrl;

   while (url) {
      const response = await fetch(url, { headers });

      if (!response.ok) {
         throw new Error(`${response.status} ${response.statusText} for ${url}`);
      }

      const page = await response.json();

      items.push(...page);

      const linkNext = nextLink(response.headers.get('link'));

      if (linkNext) {
         url = linkNext;
         continue;
      }

      const nextPage = response.headers.get('x-next-page');

      if (nextPage) {
         const nextUrl = new URL(url);

         nextUrl.searchParams.set('page', nextPage);
         url = nextUrl.toString();
      } else {
         url = null;
      }
   }

   return items;
}

const PROVIDERS = {
   async github(scope, token) {
      const headers = { 'Accept': 'application/vnd.github+json', 'User-Agent': 'clone-repos' };

      if (token) {
         headers.Authorization = `Bearer ${token}`;
      }

      let repos;

      try {
         repos = await fetchAllPages(`https://api.github.com/orgs/${scope}/repos?per_page=100`, headers);
      } catch(error) {
         if (error.message.startsWith('404')) {
            repos = await fetchAllPages(`https://api.github.com/users/${scope}/repos?per_page=100`, headers);
         } else {
            throw error;
         }
      }

      return repos.filter((repo) => {
         return !repo.archived;
      }).map((repo) => {
         return { path: `${scope}/${repo.name}`, sshUrl: repo.ssh_url };
      });
   },

   async gitlab(scope, token, host) {
      const headers = {};

      if (token) {
         headers['PRIVATE-TOKEN'] = token;
      }

      const encoded = encodeURIComponent(scope),
            url = `https://${host}/api/v4/groups/${encoded}/projects?include_subgroups=true&per_page=100&archived=false`,
            projects = await fetchAllPages(url, headers);

      return projects.map((project) => {
         return { path: project.path_with_namespace, sshUrl: project.ssh_url_to_repo };
      });
   },
};

function providerFor(host) {
   return host === 'github.com' ? 'github' : 'gitlab';
}

function cloneRepo(sshUrl, dir) {
   const result = spawnSync('git', [ 'clone', sshUrl, dir ], { stdio: 'inherit' });

   if (result.status !== 0) {
      throw new Error(`git clone exited ${result.status}`);
   }
}

async function main() {
   const [ target, tokenArg ] = process.argv.slice(2);

   if (!target) {
      usage();
   }

   const { host, scope } = parseTarget(target),
         token = tokenArg || null,
         repos = await PROVIDERS[providerFor(host)](scope, token, host);

   let cloned = 0,
       skipped = 0,
       errors = 0;

   for (const { path, sshUrl } of repos) {
      const dir = join(process.cwd(), path);

      try {
         if (existsSync(dir)) {
            console.log(`[skip] ${path} (exists)`);
            skipped += 1;
            continue;
         }

         mkdirSync(dirname(dir), { recursive: true });
         console.log(`[clone] ${path}`);
         cloneRepo(sshUrl, dir);
         cloned += 1;
      } catch(error) {
         console.error(`[error] ${path}: ${error.message}`);
         errors += 1;
      }
   }

   console.log(`done: ${cloned} cloned, ${skipped} skipped, ${errors} errors`);

   if (errors > 0) {
      process.exit(1);
   }
}

main().catch((error) => {
   console.error(error.message);
   process.exit(1);
});
