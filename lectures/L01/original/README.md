# Lecture 1 data: satellite scene metadata over Mumbai, 2025

These are the original files for `L01_shell.ipynb`. Do not change them: the notebook's first cell
copies them to `../work/`, and you work on that copy.

## What is in here
- `scenes/`: one small text file per satellite scene: 88 Sentinel-2 L2A scenes (tile T43QBB) and
  46 Landsat 8/9 Collection 2 Level-2 scenes (WRS-2 path 148, row 47), all acquired over Mumbai in 2025.
  File names are the real product names. The contents are a simplified subset of each scene's metadata,
  reformatted for this lecture, so they are not the complete metadata files you would download with a scene.
- `messy/`: a few more copies of these files.
- `SHA256SUMS`: a checksum for every file. From this folder, `sha256sum -c SHA256SUMS` tells you whether anything changed.

## Where the data came from
The metadata was retrieved on 2026-09-19 from the Earth Search (Element 84) STAC catalogue (sentinel-2-l2a and
landsat-c2-l2 collections), by searching for every scene that covers the point
(72.88 E, 19.07 N) during 2025. You will search a STAC catalogue yourself in Lecture 6.

## Licences
- Sentinel-2: contains modified Copernicus Sentinel data 2025.
- Landsat: courtesy of the U.S. Geological Survey; public domain.
