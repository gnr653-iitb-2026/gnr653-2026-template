#!/usr/bin/env bash
# Pull course updates (environment files, lecture notebooks) from the course template repo
# into your own repo, without touching your assignment work.
#
# Usage (from the repo root, inside your codespace):
#     bash scripts/update_from_template.sh
set -euo pipefail

TEMPLATE_URL="https://github.com/gnr653-iitb-2026/gnr653-2026-template.git"

# Paths owned by the course. Your assignment folders are never listed here.
COURSE_PATHS=(
  ".devcontainer"
  "pyproject.toml"
  "uv.lock"
  ".python-version"
  "scripts"
  "lectures"
  "check_setup.ipynb"
)

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$TEMPLATE_URL"
fi
git fetch upstream main

# Only check out course paths that exist in the template.
paths=()
for p in "${COURSE_PATHS[@]}"; do
  if git cat-file -e "upstream/main:$p" 2>/dev/null; then
    paths+=("$p")
  fi
done
git checkout upstream/main -- "${paths[@]}"

uv sync --locked

git add -- "${paths[@]}"
if git diff --cached --quiet; then
  echo "Already up to date."
else
  git commit -m "Update course files from template"
  echo "Course files updated and committed. Run 'git push' to save them to GitHub."
fi
