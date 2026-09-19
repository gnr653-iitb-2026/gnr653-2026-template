# GNR 653: Data Analysis Methods for Geospatial Applications
This is your personal repository for GNR 653's Software Carpentry section. All your in-class and take-home work lives here. We will use github CodeSpaces for class activities. It gives you some compute that can be used to carry out assignments regardless of what computer you may have.
## Open your workspace
1. On your repo's GitHub page, click **Code > Codespaces > Create codespace on main** (first time), or open your existing codespace from https://github.com/codespaces.
2. The first build takes about 3 to 5 minutes. Later, resuming takes about 30 seconds.
3. Open `check_setup.ipynb`, choose the kernel **GNR653 (uv)**, and click **Run All**.
## What is in here
| Path | What it is |
|---|---|
| `pyproject.toml`, `uv.lock`, `.python-version` | The Python environment, managed by uv. Do not edit unless told to. |
| `check_setup.ipynb` | HW0 environment check. |
| `lectures/L01/` | Everything for Lecture 1: the notebook, the original data (`original/`), your working copy of the data (`work/`) and a scratch folder (`sandbox/`). Each lecture gets its own folder: `lectures/L02/`, `lectures/L03/`, and so on. Do not edit the notebook or `original/`; they are updated by the course. |
| `lectures/L01/ic01/` | Your in-class assignment for Lecture 1. You create it during class. The in-class assignment (IC) for Lecture 2 goes in `lectures/L02/ic02/`, and so on. |
| `th1/`, `th2/`, `th3/` | Your take-home assignments. |
## Everyday commands you may need
```bash
uv run python <my_script.py>            # run a script in the course environment
uv run jupyter lab                      # start JupyterLab (VS Code notebooks also work)
bash scripts/update_from_template.sh    # get new lecture notebooks and environment updates
git add . && git commit -m "<message>" && git push   
                                        # save your work to GitHub
```
## Rules that protect your work
- **Commit and push before you close the codespace.** A codespace unused for 30 days is deleted, together with anything not pushed.
- A codespace stops after 30 minutes of inactivity. Files are kept; variables in running notebooks are lost.
- Do not commit data files. Fetch data in code (see `.gitignore`).
- Keep one codespace for this repo and delete any extras at https://github.com/codespaces, so you stay within the free monthly allowance.
