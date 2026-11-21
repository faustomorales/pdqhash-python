# -*- coding: utf-8 -*-

import pathlib
import sys
from setuptools import setup
from setuptools.extension import Extension
import numpy


COMPILE_ARGS = ["/std:c++14"] if sys.platform == "win32" else ["-std=c++11"]

EXTENSIONS = [
    Extension(
        "pdqhash.bindings",
        ["pdqhash/bindings.pyx"],
        include_dirs=["ThreatExchange", "include", numpy.get_include()],
        language="c++",
        extra_compile_args=COMPILE_ARGS,
    )
]

exec(pathlib.Path("pdqhash/_version.py").read_text())
setup(ext_modules=EXTENSIONS, version=__version__)  # type: ignore
