#!/usr/bin/env bash

set -e

BRANCH="${1%/}"

if [ -z "${BRANCH}" ]; then
   echo "Usage: prunetree <branch-name>" >&2
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR=$("${SCRIPT_DIR}/find-worktree-root.sh")
REPO_ROOT="${PARENT_DIR}/master"
FOLDER_NAME="${BRANCH//\//_}"
WORKTREE_PATH="${PARENT_DIR}/${FOLDER_NAME}"

if [ ! -d "${WORKTREE_PATH}" ]; then
   echo "ERROR: worktree not found at ${WORKTREE_PATH}" >&2
   exit 1
fi

if [ -n "$(git -C "${WORKTREE_PATH}" status --porcelain)" ]; then
   echo "WARNING: ${WORKTREE_PATH} has uncommitted changes" >&2
   git -C "${WORKTREE_PATH}" status --short >&2
   read -p "Continue anyway? [y/N] " CONFIRM
   if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
      echo "Aborted" >&2
      exit 1
   fi
fi

git -C "${REPO_ROOT}" worktree remove --force "${WORKTREE_PATH}" >&2
echo "Pruned worktree ${FOLDER_NAME}" >&2

case "${PWD}" in
   "${WORKTREE_PATH}"*)
      echo "cd \"${PARENT_DIR}\""
      ;;
esac
