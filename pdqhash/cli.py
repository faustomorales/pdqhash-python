"""Command-line interface for computing 256-bit PDQ perceptual image hashes."""

from __future__ import annotations

import argparse
import os
import sys
from typing import Sequence

import numpy as np

from .bindings import compute, compute_dihedral

LOW_QUALITY_THRESHOLD = 50
LOW_QUALITY_EXIT_CODE = 3

DIHEDRAL_NAMES: tuple[str, ...] = (
    "ORIGINAL",
    "ROTATE90",
    "ROTATE180",
    "ROTATE270",
    "FLIPX",
    "FLIPY",
    "FLIPPLUS1",
    "FLIPMINUS1",
)


def _bits_to_hex(bits: np.ndarray) -> str:
    return np.packbits(np.asarray(bits, dtype=np.uint8)).tobytes().hex()


def _load_rgb_image(path: str) -> np.ndarray:
    if not os.path.isfile(path):
        raise FileNotFoundError(f"file not found: {path}")

    try:
        from PIL import Image  # type: ignore[import-not-found]
    except ImportError:
        Image = None

    if Image is not None:
        with Image.open(path) as img:
            rgb = img.convert("RGB")
            return np.ascontiguousarray(rgb, dtype=np.uint8)

    try:
        import cv2  # type: ignore[import-not-found]
    except ImportError as exc:
        raise RuntimeError(
            'no image decoder installed; install Pillow via `pip install "pdqhash[cli]"`'
        ) from exc

    bgr = cv2.imread(path, cv2.IMREAD_COLOR)
    if bgr is None:
        raise ValueError(f"unable to decode image: {path}")
    return np.ascontiguousarray(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB), dtype=np.uint8)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="pdq",
        usage="pdq [options] file",
        description=(
            "Hashes images with the PDQ algorithm.\n\n"
            "Output format depends on the options:\n"
            "  default: pdq hash in hex to stdout\n"
            "  quality: pdq hash in hex, then a comma, then quality from 0-100\n"
            "  dihedral: pdq hash in hex, space, then rotation name"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("file", help="path to input image file")
    parser.add_argument(
        "-d",
        "--dihedral",
        action="store_true",
        help="compute the 8 dihedral rotations",
    )
    parser.add_argument(
        "-q",
        "--quality",
        action="store_true",
        help="include the quality in the output",
    )
    parser.add_argument(
        "-l",
        "--allow-low-quality",
        action="store_true",
        help="don't abort if quality is low",
    )
    return parser


def _format_entry(hex_digest: str, quality: int, include_quality: bool) -> str:
    if include_quality:
        return f"{hex_digest},{quality}"
    return hex_digest


def run_cli(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        image = _load_rgb_image(args.file)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 2

    if args.dihedral:
        vectors, quality = compute_dihedral(image)
        if quality < LOW_QUALITY_THRESHOLD and not args.allow_low_quality:
            print(f"image quality is too low ({quality})", file=sys.stderr)
            return LOW_QUALITY_EXIT_CODE
        for vec, name in zip(vectors, DIHEDRAL_NAMES):
            prefix = _format_entry(_bits_to_hex(vec), int(quality), args.quality)
            print(f"{prefix} {name}")
        return 0

    vec, quality = compute(image)
    if quality < LOW_QUALITY_THRESHOLD and not args.allow_low_quality:
        print(f"image quality is too low ({quality})", file=sys.stderr)
        return LOW_QUALITY_EXIT_CODE

    print(_format_entry(_bits_to_hex(vec), int(quality), args.quality))
    return 0


def main() -> None:
    sys.exit(run_cli())


if __name__ == "__main__":
    main()
