import os

import cv2
import numpy as np
import pytest

from pdqhash.cli import DIHEDRAL_NAMES, run_cli


def test_cli_default_and_quality(capsys):
    img_path = os.path.join("tests", "images", "image1.jpg")

    rc = run_cli([img_path])
    captured = capsys.readouterr()
    assert rc == 0
    hex_hash = captured.out.strip()
    assert len(hex_hash) == 64
    int(hex_hash, 16)
    assert captured.err == ""

    rc_q = run_cli(["-q", img_path])
    captured_q = capsys.readouterr()
    assert rc_q == 0
    assert captured_q.out.strip() == f"{hex_hash},100"


def test_cli_dihedral_and_dihedral_quality(capsys):
    bridge_path = os.path.join(
        "ThreatExchange", "pdq", "data", "reg-test-input", "dih", "bridge-1-original.jpg"
    )

    rc = run_cli(["-d", bridge_path])
    lines = capsys.readouterr().out.strip().splitlines()
    assert rc == 0
    assert len(lines) == 8
    for line, expected_name in zip(lines, DIHEDRAL_NAMES):
        digest, rot_name = line.split(" ")
        assert len(digest) == 64
        int(digest, 16)
        assert rot_name == expected_name

    rc_dq = run_cli(["-dq", bridge_path])
    lines_dq = capsys.readouterr().out.strip().splitlines()
    assert rc_dq == 0
    assert len(lines_dq) == 8
    assert lines_dq[0].endswith(",100 ORIGINAL")


def test_cli_low_quality_abort_and_override(tmp_path, capsys):
    low_q_path = str(tmp_path / "flat.png")
    flat = np.zeros((64, 64, 3), dtype=np.uint8)
    cv2.imwrite(low_q_path, flat)

    rc = run_cli(["-q", low_q_path])
    captured = capsys.readouterr()
    assert rc == 3
    assert captured.out == ""
    assert "image quality is too low (0)" in captured.err

    rc_allow = run_cli(["-lq", low_q_path])
    captured_allow = capsys.readouterr()
    assert rc_allow == 0
    assert captured_allow.err == ""
    digest, qual = captured_allow.out.strip().split(",")
    assert len(digest) == 64
    assert qual == "0"


@pytest.mark.parametrize("missing", ["nonexistent_image_12345.png"])
def test_cli_missing_file_returns_error(missing, capsys):
    rc = run_cli([missing])
    captured = capsys.readouterr()
    assert rc == 2
    assert "file not found" in captured.err
