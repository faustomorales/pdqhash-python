# pdqhash-python

These are Python bindings to the PDQ perceptual hash released by Facebook. Note that the bindings are provided under the MIT license but the PDQ source code is licensed separately under its own license (see the `ThreatExchange/hashing/pdq` folder).

## Installation

```
pip install pdqhash
```

## Usage

```python
import pdqhash

image = cv2.imread(os.path.join('tests', 'images', image_name))
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
hash_vector, quality = pdqhash.compute(image)

# Get all the rotations and flips in one pass.
# hash_vectors is a list of vectors in the following order
# - Original
# - Rotated 90 degrees
# - Rotated 180 degrees
# - Rotated 270 degrees
# - Flipped vertically
# - Flipped horizontally
# - Rotated 90 degrees and flipped vertically
# - Rotated 90 degrees and flipped horizontally
hash_vectors, quality = pdqhash.compute_dihedral(image)

# Get the floating point values of the hash.
hash_vector_float, quality = pdqhash.compute_float(image)
```

## Contributing

- Set up local development using `make init` (you need to have `pipenv` installed)
- Run tests using `make test`
- Run tests in Docker using `make docker_test`

## Publishing New Versions
To publish a new version, do the following:

1. Bump the version number in `pdqhash/_version.py`
2. Create a new tag (e.g., `v0.2.8`) for the new version.
3. Push to GitHub.
4. Run the build workflow.
5. Download the artifacts and publish to PyPi. Note that you will have to delete the Linux wheels because, for some reason, the manylinux Docker image is currently not creating manylinux wheels.