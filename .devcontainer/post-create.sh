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
# On conda-forge the GDAL programs live in a dependency (libgdal-core), and pixi global only
# exposes programs from the packages named on the command line. So install GDAL with all
# format drivers (libgdal) into an environment called "gdal", then expose the programs by name.
pixi global install --environment gdal gdal libgdal
# (The Python scripts such as gdal_calc and gdal_merge, and the new "gdal" CLI, are exposed automatically.)
GDAL_TOOLS=(gdalinfo gdalwarp gdal_translate gdaladdo gdalbuildvrt gdaldem gdal_rasterize
            gdallocationinfo gdalsrsinfo gdal_contour gdal_grid gdaltindex ogrinfo ogr2ogr)
for t in "${GDAL_TOOLS[@]}"; do
  pixi global expose add --environment gdal "$t=$t" >/dev/null 2>&1 || echo "    (skipped $t: not in this GDAL build)"
done
gdalinfo --version

echo "==> Registering the Jupyter kernel"
uv run python -m ipykernel install --user --name gnr653 --display-name "GNR653 (uv)"

echo "==> Making uv and pixi available in every new terminal"
grep -q 'GNR653 PATH' ~/.bashrc || cat >> ~/.bashrc <<'EOF'
# GNR653 PATH
export PATH="$HOME/.local/bin:$HOME/.pixi/bin:$PATH"
EOF

echo "==> Done. Open check_setup.ipynb and choose the kernel 'GNR653 (uv)' or the .venv interpreter."
