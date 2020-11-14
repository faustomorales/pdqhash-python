# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools.extension import Extension
import numpy

EXTENSIONS = [
    Extension(
        'pdqhash.bindings', ['pdqhash/bindings.pyx'],
        include_dirs=['ThreatExchange', numpy.get_include()],
        language='c++',
        extra_compile_args=['--std=c++11'])
]

setup(ext_modules=EXTENSIONS)
