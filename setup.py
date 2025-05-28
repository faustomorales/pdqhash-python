# -*- coding: utf-8 -*-

import pathlib
from setuptools import setup
from setuptools.extension import Extension
import numpy


EXTENSIONS = [
    Extension(
        "pdqhash.bindings",
        ["pdqhash/bindings.pyx"],
        include_dirs=["ThreatExchange", "include", numpy.get_include()],
        language="c++",
        extra_compile_args=["--std=c++11"],
    )
]

exec(pathlib.Path("pdqhash/_version.py").read_text())
setup(ext_modules=EXTENSIONS, version=__version__)  # type: ignore
