#!/usr/bin/env python3
"""Resolve LibreQuake's conditional compilation the way its `build.py`
builds the NetQuake progs (`fteqcc -D__LIBREQUAKE__`, without `__QW__`).

Usage: python3 -I preprocess.py QCSRC_DIR OUT_DIR

Copies every `.qc` file under QCSRC_DIR to OUT_DIR, keeping only the lines
in branches that are taken. Removed lines become empty, so line numbers
still match the original. `#define`s are kept as they are; only `#ifdef`,
`#ifndef`, `#else` and `#endif` on `__QW__`/`__LIBREQUAKE__` (and nested
conditionals inside them) are resolved.
"""

import pathlib
import re
import sys

DEFINED = {"__LIBREQUAKE__"}
COND = re.compile(r"^\s*#\s*(ifdef|ifndef|if|else|elif|endif)\b\s*(\w*)")


def process(text):
    out = []
    # Stack of (this branch taken, any branch taken, parent active).
    stack = []
    active = True
    for line in text.split("\n"):
        m = COND.match(line)
        if m:
            kind, name = m.groups()
            if kind in ("ifdef", "ifndef"):
                taken = (name in DEFINED) == (kind == "ifdef")
                stack.append((taken, active))
                active = active and taken
            elif kind == "if":
                sys.exit(f"unsupported `#if`: {line}")
            elif kind == "elif":
                sys.exit(f"unsupported `#elif`: {line}")
            elif kind == "else":
                taken, parent = stack[-1]
                stack[-1] = (not taken, parent)
                active = parent and not taken
            elif kind == "endif":
                _, parent = stack.pop()
                active = parent
            out.append("")
            continue
        out.append(line if active else "")
    if stack:
        sys.exit("unterminated conditional")
    return "\n".join(out)


def main():
    src, dst = map(pathlib.Path, sys.argv[1:3])
    for f in sorted(src.rglob("*.qc")) + sorted(src.rglob("*.src")):
        rel = f.relative_to(src)
        out = dst / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(process(f.read_text(encoding="latin-1")), encoding="latin-1")
        print(out)


if __name__ == "__main__":
    main()
