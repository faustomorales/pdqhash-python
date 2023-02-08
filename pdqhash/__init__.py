from .bindings import compute, compute_dihedral, compute_float
import warnings
warnings.warn(
    "Hash vector order changed between version 0.1.8 and 0.2.0. "
    "See https://github.com/faustomorales/pdqhash-python/issues/1 for more details.")
from . import _version
__version__ = _version.get_versions()['version']
