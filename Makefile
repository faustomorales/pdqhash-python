ifeq ($(OS),Windows_NT)
	PYTHON = .venv/Scripts/python.exe
else
	PYTHON = .venv/bin/python
endif

init:
	python -m venv .venv
	$(PYTHON) -m pip install -r requirements.txt
	$(PYTHON) -m pip install -e .
test:
	$(PYTHON) -m pytest -s
package:
	rm -rf dist
	$(PYTHON) -m pip install build
	$(PYTHON) -m build
manylinux-wheel-docker:
	docker run --rm -v $(PWD):/io --workdir /io quay.io/pypa/manylinux_2_28_x86_64 make PYTHON_VERSION=3.13 manylinux-wheel
manylinux-wheel: PYBIN = "/opt/python/cp$(subst .,,$(PYTHON_VERSION))-cp$(subst .,,$(PYTHON_VERSION))/bin"
manylinux-wheel:
	rm -rf dist wheelhouse
	$(PYBIN)/pip install -r requirements.txt build
	$(PYBIN)/python -m build --sdist --outdir dist
	$(PYBIN)/pip wheel . --no-deps -w wheelhouse
	auditwheel repair wheelhouse/*.whl -w dist
	rm -rf wheelhouse
