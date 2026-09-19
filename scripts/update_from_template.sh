#!/usr/bin/env bash
# Get course updates (environment files, lecture notebooks and data) from the course template.
#
# Two areas in your repo:
#   lectures/  course files. This script updates them; do not edit them.
#   mine/      your work: your copy of each lecture notebook, your assignments (mine/L01/ic01/, ...),
#              your working data and scratch files. This script never changes or commits anything there.
#
# Usage (from anywhere inside your repo):
#     bash scripts/update_from_template.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

TEMPLATE_URL="https://github.com/gnr653-iitb-2026/gnr653-2026-template.git"

# Paths owned by the course.
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

# The exact list of course files in the template (NUL-separated, so spaces in names are safe).
mapfile -d '' -t files < <(git ls-tree -r -z --name-only upstream/main -- "${COURSE_PATHS[@]}")
if [ "${#files[@]}" -eq 0 ]; then
  echo "No course files found in the template. Nothing to do."
  exit 0
fi

# Update just those files (working tree and index). Nothing outside them is touched.
git checkout upstream/main -- "${files[@]}"

uv sync --locked

if git diff --cached --quiet HEAD -- "${files[@]}"; then
  echo "Course files already up to date."
else
  # Commit only the course files, even if you have other changes staged.
  git commit --quiet -m "Update course files from template" -- "${files[@]}"
  echo "Course files updated and committed. Run 'git push' to save them to GitHub."
fi

# Give each lecture its own folder in mine/ with your copy of the notebook. Existing copies are never
# overwritten. To get a fresh copy later, rename yours and run this script again.
for nb in lectures/L*/L*.ipynb; do
  [ -e "$nb" ] || continue
  lec="$(basename "$(dirname "$nb")")"
  dest="mine/$lec/$(basename "$nb")"
  if [ ! -e "$dest" ]; then
    mkdir -p "mine/$lec"
    cp "$nb" "$dest"
    echo "New: $dest (your copy of the notebook: open this one)"
  fi
done
