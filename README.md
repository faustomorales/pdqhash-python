# pdqhash-python
These are Python bindings to the PDQ perceptual hash released by Facebook. Note that the bindings are provided under the MIT license but the PDQ source code is licensed separately under its own license (see the `ThreatExchange/hashing/pdq` folder).

## Installation

```
pip install pdqhash
```

## Usage

```
import pdqhash

image = cv2.imread(os.path.join('tests', 'images', image_name))
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
hash_vector, quality = pdqhash.compute(image)
```

## Contributing
- Set up local development using `make init` (you need to have `pipenv` installed)
- Run tests using `make test`
- Run tests in Docker using `make docker_test`