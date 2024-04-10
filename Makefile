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
	$(PYTHON) setup.py sdist bdist_wheel
manylinux-wheel: PYBIN = "/opt/python/cp$(subst .,,$(PYTHON_VERSION))-cp$(subst .,,$(PYTHON_VERSION))/bin"
manylinux-wheel:
	rm -rf dist
	$(PYBIN)/pip install -r requirements.txt
	$(PYBIN)/python setup.py sdist bdist_wheel
