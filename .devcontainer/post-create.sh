#!/usr/bin/env bash
# Runs once when a codespace is created. Takes about 3 to 5 minutes.
# The log is visible in the codespace via: Command Palette > "Codespaces: View Creation Log".
set -euo pipefail

echo "==> Installing uv (Python environment manager)"
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

echo "==> Installing pixi (for the GDAL command-line tools)"
curl -fsSL https://pixi.sh/install.sh | bash
export PATH="$HOME/.pixi/bin:$PATH"

echo "==> Creating the Python environment from uv.lock"
uv sync --locked

echo "==> Installing GDAL command-line tools (gdalinfo, gdalwarp, ogr2ogr, ...)"
pixi global install gdal

echo "==> Registering the Jupyter kernel"
uv run python -m ipykernel install --user --name gnr653 --display-name "GNR653 (uv)"

echo "==> Making uv and pixi available in every new terminal"
grep -q 'GNR653 PATH' ~/.bashrc || cat >> ~/.bashrc <<'EOF'
# GNR653 PATH
export PATH="$HOME/.local/bin:$HOME/.pixi/bin:$PATH"
EOF

echo "==> Done. Open check_setup.ipynb and choose the kernel 'GNR653 (uv)' or the .venv interpreter."
