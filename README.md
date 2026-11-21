# pdqhash-python

Python bindings and CLI for the PDQ perceptual image hash released by Meta ThreatExchange. The Python bindings are licensed under the MIT license, and the bundled PDQ C++ reference implementation carries its own BSD-style license in `ThreatExchange/pdq/LICENSE.txt`.

## Installation

Install the core NumPy bindings:

```bash
pip install pdqhash
```

Install with `Pillow` image-decoding support for the `pdq` command-line tool:

```bash
pip install "pdqhash[cli]"
```

## Python Usage

```python
import cv2
import pdqhash

image = cv2.imread("tests/images/image1.jpg")
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
hash_vector, quality = pdqhash.compute(image)

# Compute all 8 dihedral rotations and flips in one pass:
# [ORIGINAL, ROTATE90, ROTATE180, ROTATE270, FLIPX, FLIPY, FLIPPLUS1, FLIPMINUS1]
hash_vectors, quality = pdqhash.compute_dihedral(image)

# Compute floating-point DCT surface values prior to median quantization:
hash_vector_float, quality = pdqhash.compute_float(image)
```

## Command-Line Interface (`pdq`)

```bash
# Default 64-character hex digest
pdq image.png

# Include quality score (0-100)
pdq -q image.png

# Compute all 8 dihedral rotations with quality scores
pdq -dq image.png

# Output hashes even when image quality is below 50 (otherwise exits with code 3)
pdq -lq low_quality.png
```

## Contributing

- Initialize a local `.venv` development environment using `make init`.
- Run the test suite using `make test`.
- Build source and wheel distributions locally using `make package`.

## Publishing New Versions

1. Update the version string in `pdqhash/_version.py`.
2. Tag the release commit (for example, `v0.2.9`) and push to GitHub.
3. Trigger the `pdqhash-python CI/CD` workflow in GitHub Actions.
4. Download the merged `dist` artifact containing Windows, macOS, `manylinux`, and sdist packages and upload with `twine upload dist/*`.
