#!/bin/sh
# Build the reference LibreQuake progs and lq-zig at -O0 and -O3, and check
# each pair with compare_progs.py. Reference builds use copies of qcsrc, so
# LibreQuake's own lq1/progs.dat is never overwritten.
#
# Usage (from lq-zig/): tools/verify.sh [path/to/LibreQuake]
set -eu
lq=${1:-../../LibreQuake}
zigqc=../target/debug/zig-qc
work=${TMPDIR:-/tmp}/lq-zig-verify
status=0
for n in 0 3; do
    ref=$work/ref-O$n
    rm -rf "$ref" && mkdir -p "$ref/lq1" "$work"
    cp -R "$lq/qcsrc" "$ref/qcsrc"
    (cd "$ref" && fteqcc -Tstandard qcsrc/progs.src -D__LIBREQUAKE__ -O$n >/dev/null)
    if ! "$zigqc" build -O$n >"$work/build-O$n.log" 2>&1; then
        tail -30 "$work/build-O$n.log"
        exit 1
    fi
    cp zig-out/lib/progs.dat "$work/lqzig-O$n.dat"
    echo "== -O$n"
    python3 -I tools/compare_progs.py "$ref/lq1/progs.dat" "$work/lqzig-O$n.dat" || status=1
done
exit $status
