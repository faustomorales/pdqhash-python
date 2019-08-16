# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools.extension import Extension
import numpy

EXTENSIONS = [
    Extension(
        'pdqhash.bindings', ['pdqhash/bindings.pyx'],
        include_dirs=['ThreatExchange/hashing',
                      numpy.get_include()],
        language='c++')
]

setup(ext_modules=EXTENSIONS)
