#!/usr/bin/env bash

function _prunetree_completions {
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   PARENT_DIR=$("${SCRIPT_DIR}/find-worktree-root.sh" 2>/dev/null) || return
   REPO_ROOT="${PARENT_DIR}/master"

   WORKTREES=$(git -C "${REPO_ROOT}" worktree list --porcelain 2>/dev/null \
      | grep '^branch ' \
      | sed 's|^branch refs/heads/||' \
      | grep -v '^master$')
   COMPREPLY=($(compgen -W "${WORKTREES}" -- "${COMP_WORDS[1]}"))
}

complete -F _prunetree_completions prunetree
