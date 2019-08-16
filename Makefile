TEST_SCOPE?=tests/

IMAGE_NAME = pdqhash
DOCKER_ARGS = -v $(PWD)/tests:/usr/src/tests
IN_DOCKER = docker run $(DOCKER_ARGS) $(IMAGE_NAME)
TEST_SCOPE?=tests/

.PHONY: build
init:
	PIPENV_VENV_IN_PROJECT=true pipenv install --dev --skip-lock
	pipenv run pip install -e .
test:
	pipenv run pytest $(TEST_SCOPE)
docker_build:
	docker build --rm --force-rm -t $(IMAGE_NAME) .
docker_test: docker_build
	$(IN_DOCKER) make test
docker_bash:
	docker run -it $(DOCKER_ARGS) $(IMAGE_NAME) bash
package:
	rm -rf dist 
	pipenv run python setup.py sdist