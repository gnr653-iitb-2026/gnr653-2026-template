#!/usr/bin/env bash
# Runs once when a codespace is created (onCreateCommand). Takes about 3 to 5 minutes, and the
# editor waits until it finishes. The log: Command Palette > "Codespaces: View Creation Log".
# To re-run by hand: bash .devcontainer/post-create.sh
set -euo pipefail
trap 'echo "!!! GNR653 SETUP FAILED at line $LINENO. Re-run: bash .devcontainer/post-create.sh" >&2; df -h / /workspaces >&2' ERR

echo "==> Disk space before setup"
df -h / /workspaces
# Caches go on the /workspaces disk (set in devcontainer.json). If that parent folder is not
# writable, fall back to .cache/ inside the repo (same disk, ignored by git).
if ! mkdir -p "${UV_CACHE_DIR:-$HOME/.cache/uv}" "${PIXI_CACHE_DIR:-$HOME/.cache/pixi}" 2>/dev/null; then
  export UV_CACHE_DIR="$PWD/.cache/uv" PIXI_CACHE_DIR="$PWD/.cache/pixi"
  mkdir -p "$UV_CACHE_DIR" "$PIXI_CACHE_DIR"
fi
echo "    uv cache: $UV_CACHE_DIR"

echo "==> Installing uv (Python environment manager)"
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

echo "==> Installing pixi (for the GDAL command-line tools)"
curl -fsSL https://pixi.sh/install.sh | bash
export PATH="$HOME/.pixi/bin:$PATH"

echo "==> Creating the Python environment from uv.lock"
uv sync --locked
uv cache prune --ci   # drop downloaded archives, keep only what the environment uses

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
rm -rf "${PIXI_CACHE_DIR:-$HOME/.cache/pixi}"   # the environment is installed; the package cache is not needed

echo "==> Registering the Jupyter kernel"
uv run python -m ipykernel install --user --name gnr653 --display-name "GNR653 (uv)"

echo "==> Making uv and pixi available in every new terminal"
grep -q 'GNR653 PATH' ~/.bashrc || cat >> ~/.bashrc <<'EOF'
# GNR653 PATH
export PATH="$HOME/.local/bin:$HOME/.pixi/bin:$PATH"
EOF

touch "$HOME/.gnr653-setup-complete"
echo "==> Disk space after setup"
df -h / /workspaces
echo "==> Done. Open check_setup.ipynb and choose the kernel 'GNR653 (uv)' or the .venv interpreter."
