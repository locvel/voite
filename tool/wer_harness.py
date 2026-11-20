#!/usr/bin/env python3
"""Compute word error rate for a reference and a recognizer transcript.

Install the small dependency with: python3 -m pip install jiwer
Usage: python3 tool/wer_harness.py reference.txt hypothesis.txt
"""

import argparse
from pathlib import Path

from jiwer import wer


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("reference", type=Path, help="ground-truth transcript")
    parser.add_argument("hypothesis", type=Path, help="recognizer output transcript")
    args = parser.parse_args()

    reference = args.reference.read_text(encoding="utf-8").strip()
    hypothesis = args.hypothesis.read_text(encoding="utf-8").strip()
    if not reference:
        parser.error("reference transcript is empty")
    score = wer(reference, hypothesis)
    print(f"WER: {score * 100:.2f}%")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
