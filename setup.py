# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools.extension import Extension
from Cython.Build import cythonize
import numpy

extensions = [
    Extension(
        'pdqhash.bindings', ['pdqhash/bindings.pyx'],
        include_dirs=['ThreatExchange/hashing',
                      numpy.get_include()])
]

setup(ext_modules=cythonize(extensions))
