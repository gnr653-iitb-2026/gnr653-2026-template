# Lectures (course files: do not edit)
This folder belongs to the course. `bash scripts/update_from_template.sh` keeps it up to date and overwrites anything changed here, so never edit or save files in it.

| Path | What it is |
|---|---|
| `L01/L01_shell.ipynb` | The original Lecture 1 notebook. |
| `L01/original/` | The data for Lecture 1, with a `README.md` (where it came from, licence) and `SHA256SUMS`. |

Your own work goes in `mine/` at the top of the repo:

| Path | What it is |
|---|---|
| `mine/L01/L01_shell.ipynb` | Your copy of the notebook. Open and run this one, and add your own notes. |
| `mine/L01/work/` | Your working copy of the data, made by the notebook's first cell. Not saved in git; rerun that cell to get a fresh copy. |
| `mine/L01/sandbox/` | Scratch space for trying things in class. Not saved in git. |
| `mine/L01/ic01/` | Your in-class assignment. Commit and push it. |

Lecture 2 will be in `L02/` here and `mine/L02/` for your work, and so on. The update script creates the new `mine/` folder with a copy of each new notebook the first time, and never changes it afterwards. For a fresh copy of a notebook, rename yours and run the update script again.
