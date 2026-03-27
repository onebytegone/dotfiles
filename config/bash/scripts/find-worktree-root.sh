#!/usr/bin/env bash

SEARCH_DIR="${PWD}"
while [ "${SEARCH_DIR}" != "/" ]; do
   if [ -d "${SEARCH_DIR}/master/.git" ] || [ -f "${SEARCH_DIR}/master/.git" ]; then
      echo "${SEARCH_DIR}"
      exit 0
   fi
   SEARCH_DIR=$(dirname "${SEARCH_DIR}")
done

echo "ERROR: could not find a master worktree above ${PWD}" >&2
exit 1
