#!/usr/bin/env bash
# Get course updates: the course environment and the files for each new lecture.
#
# All your work lives in mine/, one folder per lecture:
#   mine/L01/L01_shell.ipynb   your notebook for Lecture 1 (open and run this one)
#   mine/L01/original/         the data as shipped. This script puts it back if it is changed or deleted.
#   mine/L01/work/, sandbox/   your working copy of the data and scratch space (not saved in git)
#   mine/L01/ic01/             your in-class assignment
# Lecture 2 arrives in mine/L02/, and so on.
#
# What this script does
#   - updates the course environment files (.devcontainer/, pyproject.toml, uv.lock, scripts/, ...)
#     and commits only those files;
#   - copies every new lecture file into mine/. A notebook you have changed is never overwritten.
#     A notebook you have not changed is updated if the course publishes a corrected version.
#
# Usage (from anywhere inside your repo):
#     bash scripts/update_from_template.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

TEMPLATE_URL="https://github.com/gnr653-iitb-2026/gnr653-2026-template.git"
SELF="scripts/update_from_template.sh"
RECORD="mine/.course_files"      # which course files were copied into mine/, and which version

# Paths on the main branch owned by the course.
COURSE_PATHS=(
  ".devcontainer"
  "pyproject.toml"
  "uv.lock"
  ".python-version"
  "scripts"
  "check_setup.ipynb"
)

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$TEMPLATE_URL"
fi
git fetch --quiet upstream main
git fetch --quiet upstream lectures 2>/dev/null || true

# 0. If the course has a newer version of this script, switch to it first.
if [ -z "${GNR653_UPDATE_RESTARTED:-}" ] && git cat-file -e "upstream/main:$SELF" 2>/dev/null \
   && ! git diff --quiet upstream/main -- "$SELF"; then
  git checkout upstream/main -- "$SELF"
  echo "Updated $SELF. Running the new version."
  GNR653_UPDATE_RESTARTED=1 exec bash "$SELF" "$@"
fi

# 1. Course environment files from the main branch (working tree and index). Nothing else is touched.
mapfile -d '' -t files < <(git ls-tree -r -z --name-only upstream/main -- "${COURSE_PATHS[@]}")
if [ "${#files[@]}" -gt 0 ]; then
  git checkout upstream/main -- "${files[@]}"
fi
commit_paths=("${files[@]}")

if [ "${#commit_paths[@]}" -gt 0 ]; then
  uv sync --locked
  if git diff --cached --quiet HEAD -- "${commit_paths[@]}"; then
    echo "Course environment already up to date."
  else
    # Commit only the course files, even if you have other changes staged.
    git commit --quiet -m "Update course files from template" -- "${commit_paths[@]}"
    echo "Course environment updated and committed."
  fi
fi

# 2. Lecture files from the lectures branch into mine/.
if ! git rev-parse --verify --quiet upstream/lectures >/dev/null; then
  echo "No lecture files published yet."
  exit 0
fi

declare -A copied=()                # path -> version (blob id) last copied into mine/
if [ -f "$RECORD" ]; then
  while read -r sha path; do
    [ -n "${path:-}" ] && copied["$path"]="$sha"
  done < "$RECORD"
fi

new=(); updated=(); restored=(); kept=()
while IFS= read -r -d '' entry; do
  meta="${entry%%$'\t'*}"           # "<mode> blob <id>"
  path="${entry#*$'\t'}"            # e.g. L01/L01_shell.ipynb
  sha="${meta##* }"
  case "$path" in L[0-9]*/*) ;; *) continue ;; esac
  dest="mine/$path"
  write() { mkdir -p "$(dirname "$dest")"; git cat-file blob "$sha" > "$dest"; copied["$path"]="$sha"; }

  if [ ! -e "$dest" ]; then
    if [[ "$path" == */original/* ]] && [ -n "${copied[$path]:-}" ]; then
      write; restored+=("$dest")                  # shipped data you deleted
    else
      write; new+=("$dest")
    fi
    continue
  fi
  cur="$(git hash-object -- "$dest")"
  if [ "$cur" = "$sha" ]; then
    copied["$path"]="$sha"
  elif [[ "$path" == */original/* ]]; then
    write; restored+=("$dest")                    # shipped data always matches the course version
  elif [ "$cur" = "${copied[$path]:-none}" ]; then
    write; updated+=("$dest")                     # you had not changed it: take the new version
  elif [ "${copied[$path]:-none}" != "$sha" ]; then
    kept+=("$dest")                               # you changed it and so did the course: keep yours
  fi
done < <(git ls-tree -r -z upstream/lectures)

mkdir -p mine
for p in "${!copied[@]}"; do printf '%s %s\n' "${copied[$p]}" "$p"; done | sort -k2 > "$RECORD"

show() { local title="$1"; shift; [ "$#" -gt 0 ] || return 0; echo "$title"; printf '  %s\n' "$@"; }
if [ "${#new[@]}" -eq 0 ] && [ "${#updated[@]}" -eq 0 ] && [ "${#restored[@]}" -eq 0 ] && [ "${#kept[@]}" -eq 0 ]; then
  echo "Lecture files already up to date."
fi
if [ "${#new[@]}" -gt 5 ]; then
  echo "New lecture files in mine/:"
  printf '%s\n' "${new[@]}" | cut -d/ -f1-2 | sort | uniq -c | awk '{printf "  %s/  (%d files)\n", $2, $1}'
  printf '%s\n' "${new[@]}" | grep '\.ipynb$' | sed 's/^/  open: /' || true
else
  show "New lecture files:" "${new[@]}"
fi
show "Updated to the corrected course version (you had not changed them):" "${updated[@]}"
[ "${#restored[@]}" -gt 0 ] && echo "Restored ${#restored[@]} original data file(s) that had been changed or deleted."
if [ "${#kept[@]}" -gt 0 ]; then
  show "The course has a newer version of these files, but you have changed yours, so yours is kept:" "${kept[@]}"
  echo "  To get the course version as well: rename your file (e.g. add _mine) and run this script again."
fi
if [ "${#new[@]}" -gt 0 ] || [ "${#updated[@]}" -gt 0 ]; then
  echo "Save them to GitHub:  git add mine && git commit -m \"Lecture files\" && git push"
fi
