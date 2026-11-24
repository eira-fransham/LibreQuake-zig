#!/usr/bin/env python3
"""Check that a translated `progs.dat` is compatible with a reference one.

Usage: python3 -I compare_progs.py REFERENCE.dat OURS.dat

Compatible means everything the engine, maps and savegames find by name or
offset is there:

- the same progs version and system-defs CRC;
- system globals and fields at the same offsets with the same types;
- every reference field present, with the same type (maps set fields by
  name, and savegames store them by name);
- every saved reference global present, with the same type;
- every reference function that is reached by name present, with the same
  number of parameters. That is: functions used as values (stored into a
  field or global, passed as an argument, or in a `[frame, think]` state),
  and `void()` functions the bytecode never mentions at all (spawn
  functions and engine entry points, which are found by name). Functions
  that are only called directly may have been inlined, and unreferenced
  functions with parameters are dead code; they are listed, but don't fail
  the check.

Exits with 1 if anything required is missing or mismatched.
"""

import struct
import sys

DEF_SAVEGLOBAL = 0x8000
TYPES = ["void", "string", "float", "vector", "entity", "field", "function", "pointer"]
OP_CALL0, OP_CALL8 = 51, 59
OP_IF, OP_IFNOT, OP_GOTO = 49, 50, 61


class Progs:
    def __init__(self, path):
        with open(path, "rb") as f:
            data = f.read()
        h = struct.unpack_from("<15i", data, 0)
        (self.version, self.crc, ofs_st, num_st, ofs_gd, num_gd, ofs_fd, num_fd,
         ofs_fn, num_fn, ofs_str, num_str, ofs_gl, num_gl, self.entityfields) = h
        self.strings = data[ofs_str:ofs_str + num_str]

        def defs(ofs, n):
            out = []
            for i in range(n):
                ty, o, name = struct.unpack_from("<HHi", data, ofs + i * 8)
                out.append((self.string(name), ty, o))
            return out

        self.globaldefs = defs(ofs_gd, num_gd)
        self.fielddefs = defs(ofs_fd, num_fd)
        self.statements = [struct.unpack_from("<Hhhh", data, ofs_st + i * 8) for i in range(num_st)]
        self.functions = []
        for i in range(num_fn):
            first, _parm, _locals, _prof, name, _file, numparms = struct.unpack_from(
                "<7i", data, ofs_fn + i * 36)
            self.functions.append((self.string(name), first, numparms))
        self.globals = data[ofs_gl:ofs_gl + num_gl * 4]

        self.end_sys_globals = next((o for n, _, o in self.globaldefs if n == "end_sys_globals"), None)

    def string(self, ofs):
        end = self.strings.find(b"\0", ofs)
        return self.strings[ofs:end].decode("latin-1")

    def global_int(self, ofs):
        return struct.unpack_from("<i", self.globals, ofs * 4)[0]


def type_name(ty):
    ty &= ~DEF_SAVEGLOBAL
    return TYPES[ty] if ty < len(TYPES) else f"type{ty}"


def function_uses(p):
    """Per function index: (used as a value, called directly)."""
    # Map each global offset holding a function constant to its function.
    by_ofs = {}
    for name, ty, ofs in p.globaldefs:
        if ty & ~DEF_SAVEGLOBAL == 6 and ofs < len(p.globals) // 4:
            fi = p.global_int(ofs)
            if 0 < fi < len(p.functions) and p.functions[fi][0] == name:
                by_ofs[ofs] = fi
    value, called = set(), set()
    for op, a, b, c in p.statements:
        operands = [(a, "a"), (b, "b"), (c, "c")]
        # Branch offsets aren't globals.
        if op in (OP_IF, OP_IFNOT):
            operands = [(a, "a")]
        elif op == OP_GOTO:
            operands = []
        for v, pos in operands:
            fi = by_ofs.get(v & 0xFFFF)
            if fi is None:
                continue
            if OP_CALL0 <= op <= OP_CALL8 and pos == "a":
                called.add(fi)
            else:
                value.add(fi)
    return value, called


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    ref, ours = Progs(sys.argv[1]), Progs(sys.argv[2])
    errors, notes = [], []

    if ref.version != ours.version:
        errors.append(f"version: reference {ref.version}, ours {ours.version}")
    if ref.crc != ours.crc:
        errors.append(f"CRC: reference {ref.crc}, ours {ours.crc}")

    # System globals and fields: same offsets and types.
    def sys_check(kind, rdefs, odefs, rend, oend):
        if rend is None or oend is None:
            notes.append(f"no end_sys_{kind} marker; skipping the {kind} layout check")
            return
        if rend != oend:
            errors.append(f"end_sys_{kind}: reference {rend}, ours {oend}")
        omap = {n: (ty, o) for n, ty, o in odefs}
        for n, ty, o in rdefs:
            if o >= rend or not n or n.startswith("end_sys_"):
                continue
            if kind == "globals" and type_name(ty) not in ("float", "vector", "entity", "string", "function"):
                continue
            got = omap.get(n)
            if got is None:
                errors.append(f"system {kind[:-1]} `{n}` is missing")
            elif got[1] != o or type_name(got[0]) != type_name(ty):
                errors.append(f"system {kind[:-1]} `{n}`: reference {type_name(ty)} @{o}, "
                              f"ours {type_name(got[0])} @{got[1]}")

    sys_check("globals", ref.globaldefs, ours.globaldefs, ref.end_sys_globals, ours.end_sys_globals)

    # Fields: every name, with its type.
    ofields = {n: ty for n, ty, _ in ours.fielddefs}
    missing_fields = []
    for n, ty, o in ref.fielddefs:
        if not n:
            continue
        if n not in ofields:
            missing_fields.append(n)
        elif type_name(ofields[n]) != type_name(ty):
            errors.append(f"field `{n}`: reference .{type_name(ty)}, ours .{type_name(ofields[n])}")
    if missing_fields:
        errors.append(f"{len(missing_fields)} missing fields: {' '.join(sorted(missing_fields))}")
    # System field offsets.
    ofield_ofs = {n: o for n, _, o in ours.fielddefs}
    for n, ty, o in ref.fielddefs:
        if not n or n not in ofield_ofs:
            continue
        # Fields before the first user field are system fields.
        if o < ref_sys_field_size(ref) and ofield_ofs[n] != o:
            errors.append(f"system field `{n}`: reference offset {o}, ours {ofield_ofs[n]}")

    # Saved globals.
    oglobals = {n: ty for n, ty, _ in ours.globaldefs}
    missing_globals, missing_internal = [], []
    for n, ty, o in ref.globaldefs:
        if not (ty & DEF_SAVEGLOBAL) or not n:
            continue
        if n not in oglobals:
            # fteqcc's names for array elements, e.g. `levels[0].cd_track`.
            (missing_internal if "[" in n else missing_globals).append(n)
        elif type_name(oglobals[n]) != type_name(ty):
            errors.append(f"global `{n}`: reference {type_name(ty)}, ours {type_name(oglobals[n])}")
        elif not (oglobals[n] & DEF_SAVEGLOBAL):
            errors.append(f"global `{n}` isn't saved in ours")
    if missing_internal:
        notes.append(f"{len(missing_internal)} saved array elements not present (arrays can "
                     f"be translated differently): {' '.join(sorted(missing_internal))}")
    if missing_globals:
        errors.append(f"{len(missing_globals)} missing saved globals: {' '.join(sorted(missing_globals))}")

    # Functions.
    value, called = function_uses(ref)
    ofuncs = {n: np for n, _, np in ours.functions}
    required_missing, optional_missing, dead_missing = [], [], []
    for fi, (n, first, numparms) in enumerate(ref.functions):
        if fi == 0 or not n or first < 0:  # null function, builtins
            continue
        unreferenced = fi not in value and fi not in called
        reached_by_name = fi in value or (unreferenced and numparms == 0)
        if n not in ofuncs:
            if reached_by_name:
                required_missing.append(n)
            elif unreferenced:
                dead_missing.append(n)
            else:
                optional_missing.append(n)
        elif reached_by_name and ofuncs[n] != numparms:
            errors.append(f"function `{n}`: reference takes {numparms} parameters, ours {ofuncs[n]}")
    if required_missing:
        errors.append(f"{len(required_missing)} missing functions reached by name: "
                      f"{' '.join(sorted(required_missing))}")
    if optional_missing:
        notes.append(f"{len(optional_missing)} directly-called functions not present "
                     f"(inlined or merged?): {' '.join(sorted(optional_missing))}")
    if dead_missing:
        notes.append(f"{len(dead_missing)} unreferenced functions with parameters not present "
                     f"(dead code): {' '.join(sorted(dead_missing))}")

    print(f"reference: {sys.argv[1]}: {len(ref.functions)} functions, {len(ref.fielddefs)} fields, "
          f"{len(ref.globaldefs)} globals, entityfields {ref.entityfields}")
    print(f"ours:      {sys.argv[2]}: {len(ours.functions)} functions, {len(ours.fielddefs)} fields, "
          f"{len(ours.globaldefs)} globals, entityfields {ours.entityfields}")
    for n in notes:
        print(f"note: {n}")
    for e in errors:
        print(f"error: {e}")
    print("compatible" if not errors else f"NOT compatible ({len(errors)} problems)")
    sys.exit(1 if errors else 0)


def ref_sys_field_size(p):
    """The number of system field slots: up to and including `noise3`, the
    last system field in both NetQuake and QuakeWorld."""
    for n, _, o in p.fielddefs:
        if n == "noise3":
            return o + 1
    return 0


if __name__ == "__main__":
    main()
