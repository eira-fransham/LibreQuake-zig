#!/usr/bin/env python3
"""Print the Zig `Frame` enum and helpers for a QuakeC file's `$frame` lines.

Usage: python3 -I gen_frames.py FILE.qc

Frame macros are numbered from 0 in the order they're declared in each file,
as fteqcc does (each model's file restarts the count), so `@backingInt` of
a `Frame` is the frame number. Paste the output into the file's Zig
translation; write `[$f, next]` state functions as `state(.f, next)` and a
bare `$f` as `fr(.f)`.
"""

import re
import sys

ZIG_KEYWORDS = {
    "addrspace", "align", "allowzero", "and", "anyframe", "anytype", "asm", "break",
    "callconv", "catch", "comptime", "const", "continue", "defer", "else", "enum",
    "errdefer", "error", "export", "extern", "fn", "for", "if", "inline", "linksection",
    "noalias", "noinline", "nosuspend", "opaque", "or", "orelse", "packed", "pub",
    "resume", "return", "struct", "suspend", "switch", "test", "threadlocal", "try",
    "union", "unreachable", "var", "volatile", "while",
}


def ident(n):
    return f'@"{n}"' if n in ZIG_KEYWORDS or n[0].isdigit() else n


def main():
    text = open(sys.argv[1], encoding="latin-1").read()
    frames, seen = [], set()
    for line in text.split("\n"):
        code = line.split("//")[0]
        m = re.match(r"\s*\$frame\s+(.*)", code)
        if not m:
            continue
        for name in m.group(1).split():
            if name in seen:
                sys.exit(f"duplicate frame `{name}`")
            seen.add(name)
            frames.append(name)
    if not frames:
        sys.exit("no $frame lines")
    print("/// The `$frame` macros, numbered from 0 in declaration order.")
    print("const Frame = enum(u8) {")
    for f in frames:
        print(f"    {ident(f)},")
    print("};")
    print()
    print("/// `$frame`, as a float.")
    print("inline fn fr(comptime frame: Frame) f32 {")
    print("    return @floatFromInt(@backingInt(frame));")
    print("}")
    print()
    print("/// The `[$frame, next]` prefix of a state function.")
    print("inline fn state(comptime frame: Frame, comptime next: anytype) void {")
    print("    q.setState(fr(frame), q.func(next));")
    print("}")


if __name__ == "__main__":
    main()
