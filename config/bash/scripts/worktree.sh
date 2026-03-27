#!/usr/bin/env bash

set -e

BRANCH="${1%/}"

if [ -z "${BRANCH}" ]; then
   echo "Usage: worktree <branch-name>" >&2
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR=$("${SCRIPT_DIR}/find-worktree-root.sh")
REPO_ROOT="${PARENT_DIR}/master"
FOLDER_NAME="${BRANCH//\//_}"
WORKTREE_PATH="${PARENT_DIR}/${FOLDER_NAME}"

git -C "${REPO_ROOT}" fetch origin >&2

if git -C "${REPO_ROOT}" rev-parse --verify "${BRANCH}" >/dev/null 2>&1; then
   git -C "${REPO_ROOT}" worktree add --no-checkout "${WORKTREE_PATH}" "${BRANCH}" >&2
elif git -C "${REPO_ROOT}" rev-parse --verify "origin/${BRANCH}" >/dev/null 2>&1; then
   git -C "${REPO_ROOT}" worktree add --no-checkout -b "${BRANCH}" "${WORKTREE_PATH}" "origin/${BRANCH}" >&2
else
   git -C "${REPO_ROOT}" worktree add --no-checkout -b "${BRANCH}" "${WORKTREE_PATH}" "origin/master" >&2
fi

touch -t "$(date '+%Y%m%d%H%M.%S')" "${WORKTREE_PATH}"

SYNC_LOG="${WORKTREE_PATH}/.worktree-sync.log"

(
   git -C "${WORKTREE_PATH}" checkout

   SYNC_FILE="${PARENT_DIR}/worktree-sync.txt"
   if [ -f "${SYNC_FILE}" ]; then
      while IFS= read -r FILE || [ -n "${FILE}" ]; do
         if [ -z "${FILE}" ] || [[ "${FILE}" == \#* ]]; then
            continue
         fi

         SRC="${REPO_ROOT}/${FILE}"
         DEST="${WORKTREE_PATH}/${FILE}"

         if [ ! -e "${SRC}" ]; then
            echo "WARNING: sync source not found: ${FILE}"
            continue
         fi

         mkdir -p "$(dirname "${DEST}")"

         if [ -d "${SRC}" ]; then
            cp -c -R "${SRC}/" "${DEST}/" 2>/dev/null || cp -R "${SRC}/" "${DEST}/"
         else
            cp -c "${SRC}" "${DEST}" 2>/dev/null || cp "${SRC}" "${DEST}"
         fi
      done < "${SYNC_FILE}"
   fi
) >"${SYNC_LOG}" 2>&1 &

echo "cd \"${WORKTREE_PATH}\" && vim GOAL.md && cat \"${SYNC_LOG}\""
