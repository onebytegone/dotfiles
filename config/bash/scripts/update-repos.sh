#!/usr/bin/env bash

set -e

ROOT_DIR="${1:-$PWD}"

if [ ! -d "${ROOT_DIR}" ]; then
   echo "ERROR: not a directory: ${ROOT_DIR}" >&2
   exit 1
fi

ROOT_DIR="${ROOT_DIR%/}"

FF=0
FETCHED=0
SKIPPED=0
ERRORS=0

update_repo() {
   local REPO="$1"
   local REL="${REPO#"${ROOT_DIR}"/}"

   if ! git -C "${REPO}" fetch --all --prune >/dev/null 2>&1; then
      echo "[error] ${REL}: fetch failed" >&2
      ERRORS=$((ERRORS + 1))
      return
   fi

   git -C "${REPO}" remote set-head origin --auto >/dev/null 2>&1 || true

   local DEFAULT_REF
   DEFAULT_REF=$(git -C "${REPO}" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || true)

   if [ -z "${DEFAULT_REF}" ]; then
      echo "[skip] ${REL} (no default branch)"
      SKIPPED=$((SKIPPED + 1))
      return
   fi

   local DEFAULT_BRANCH="${DEFAULT_REF#refs/remotes/origin/}"
   local CURRENT_BRANCH
   CURRENT_BRANCH=$(git -C "${REPO}" rev-parse --abbrev-ref HEAD)

   if [ "${CURRENT_BRANCH}" != "${DEFAULT_BRANCH}" ]; then
      echo "[fetch] ${REL} (on ${CURRENT_BRANCH})"
      FETCHED=$((FETCHED + 1))
      return
   fi

   if [ -n "$(git -C "${REPO}" status --porcelain)" ]; then
      echo "[skip] ${REL} (dirty)"
      SKIPPED=$((SKIPPED + 1))
      return
   fi

   if git -C "${REPO}" merge --ff-only "origin/${DEFAULT_BRANCH}" >/dev/null 2>&1; then
      echo "[ff] ${REL} ${DEFAULT_BRANCH}"
      FF=$((FF + 1))
   else
      echo "[skip] ${REL} (diverged)"
      SKIPPED=$((SKIPPED + 1))
   fi
}

scan_dir() {
   local DIR="$1"

   if [ -e "${DIR}/.git" ]; then
      update_repo "${DIR}"
      return
   fi

   local CHILD
   for CHILD in "${DIR}"/*/; do
      [ -d "${CHILD}" ] || continue
      scan_dir "${CHILD%/}"
   done
}

scan_dir "${ROOT_DIR}"

echo "done: ${FF} fast-forwarded, ${FETCHED} fetched, ${SKIPPED} skipped, ${ERRORS} errors"

if [ "${ERRORS}" -gt 0 ]; then
   exit 1
fi
