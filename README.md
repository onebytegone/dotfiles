# dotfiles

This is a repo to hold my basic CLI/bash setup. Makes it easier to setup the CLI on a new box.


## Install

```
git clone https://github.com/onebytegone/dotfiles.git ~/dotfiles
```

# Setup

```
cd dotfiles
./setup.sh
```

## Git repo mirroring

Two helper scripts live in `config/bash/scripts/` for cloning and maintaining a
local mirror of every repo under a GitHub user/org or a GitLab group (including
self-hosted GitLab).

### Clone a scope

```txt
clone-repos <host>/<scope> [token]
```

Discovers every repo under the scope via the provider API and SSH-clones each
into a scope subfolder under the current directory. The provider is inferred
from the host (`github.com` uses the GitHub API; any other host uses the GitLab
API).

```txt
cd ~/git
config/bash/scripts/clone-repos.mjs github.com/onebytegone "$(pbpaste)"
```

The optional token is used only to list repos (private repos, higher rate
limits); the clone itself uses SSH, so an authorized SSH key is required. Pass
the token as the second argument; copy it to the clipboard and use
`"$(pbpaste)"` so it stays out of your shell history. Omit it for public repos
only.

Repos land at `./<scope>/<repo>` (GitHub) or `./<group>/<subgroup>/<repo>`
(GitLab). Existing directories are skipped, so rerunning only fills in new repos.

### Update a tree (cron)

```txt
update-repos [dir]
```

Recursively finds every git repo under `dir` (default: current directory),
fetches it, and fast-forwards the default branch when it is the checked-out
branch and the working tree is clean. Repos on another branch are only fetched;
dirty or diverged repos are left untouched. It needs no token — all transport is
SSH.

Sample crontab entry (hourly, logging to a file):

```txt
0 * * * * ~/dotfiles/config/bash/scripts/update-repos.sh ~/git >> ~/git/.update-repos.log 2>&1
```
