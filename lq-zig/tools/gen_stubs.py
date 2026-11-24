#!/usr/bin/env python3
"""Generate the Zig skeleton of the LibreQuake port from the preprocessed
QuakeC (see `preprocess.py`).

Usage: python3 -I gen_stubs.py PREPROCESSED_QCSRC OUT_SRC_DIR

For every file in `progs.src` (except `defs.qc` and `localized_text.qc`,
which are translated by hand into `lq.zig` and `localized_text.zig`), this
writes `OUT_SRC_DIR/<file>.zig` containing:

- the `Frame` enum and `fr`/`state` helpers, if the file has `$frame`s;
- its top-level globals (`userGlobal`), entity fields (`userField`) and
  constants, under their QuakeC names;
- a stub for every function it defines: `pub export fn` with the QuakeC
  name and signature, a `state(...)` prefix for `[$frame, next]` functions,
  and a body of `unreachable` marked `TODO(translate)`.

So every name exists, in its final module and with its final signature,
before any body is translated, and the project type-checks throughout.
Also writes `OUT_SRC_DIR/root.zig`. Refuses to overwrite existing files
unless `--force` is given.
"""

import pathlib
import re
import sys

TY = {"float": "f32", "vector": "Vector", "string": "String", "entity": "Entity", "void": "void"}
ZIG_KEYWORDS = {
    "addrspace", "align", "allowzero", "and", "anyframe", "anytype", "asm", "break",
    "callconv", "catch", "comptime", "const", "continue", "defer", "else", "enum",
    "errdefer", "error", "export", "extern", "fn", "for", "if", "inline", "linksection",
    "noalias", "noinline", "nosuspend", "opaque", "or", "orelse", "packed", "pub",
    "resume", "return", "struct", "suspend", "switch", "test", "threadlocal", "try",
    "union", "unreachable", "var", "volatile", "while",
}
# Names the generated files already use.
RESERVED = {"q", "lq", "loc", "S", "Entity", "Vector", "String", "Function", "Frame", "fr", "state", "std"}

TOKEN = re.compile(r"""
    (?P<ws>\s+)
  | (?P<lcomment>//[^\n]*)
  | (?P<bcomment>/\*.*?\*/)
  | (?P<directive>^[ \t]*\#(?:\\\n|[^\n])*)
  | (?P<frame>^[ \t]*\$[^\n]*)
  | (?P<string>"(?:\\.|[^"\\])*")
  | (?P<vector>'[^']*')
  | (?P<number>\d+\.?\d*|\.\d+)
  | (?P<ident>[A-Za-z_][A-Za-z_0-9]*)
  | (?P<macro>\$[A-Za-z_0-9]+)
  | (?P<punct>.)
""", re.X | re.S | re.M)


def tokenize(text):
    out = []
    for m in TOKEN.finditer(text):
        kind = m.lastgroup
        if kind in ("ws", "lcomment", "bcomment"):
            continue
        out.append((kind, m.group()))
    return out


def ident(n):
    return f'@"{n}"' if n in ZIG_KEYWORDS else n


class Parser:
    def __init__(self, toks, path):
        self.t, self.i, self.path = toks, 0, path

    def peek(self, k=0):
        return self.t[self.i + k] if self.i + k < len(self.t) else (None, None)

    def next(self):
        tok = self.peek()
        self.i += 1
        return tok

    def expect(self, v):
        tok = self.next()
        if tok[1] != v:
            raise SystemExit(f"{self.path}: expected `{v}`, got `{tok[1]}` near token {self.i}")
        return tok

    def skip_balanced(self, open_, close):
        self.expect(open_)
        depth = 1
        start = self.i
        while depth:
            tok = self.next()
            if tok[0] is None:
                raise SystemExit(f"{self.path}: unbalanced `{open_}`")
            if tok[1] == open_:
                depth += 1
            elif tok[1] == close:
                depth -= 1
        return self.t[start:self.i - 1]

    def params(self):
        """`(type name, ...)` after a type; returns [(zigtype, name)]."""
        self.expect("(")
        ps = []
        while self.peek()[1] != ")":
            field = False
            if self.peek()[1] == ".":
                self.next()
                field = True
            ty = self.next()[1]
            if self.peek()[1] == "(":
                self.skip_balanced("(", ")")
                zt = "Function"
            else:
                zt = TY[ty]
            if field:
                zt = "q.Field"
            name = self.next()[1]
            ps.append((zt, name))
            if self.peek()[1] == ",":
                self.next()
        self.expect(")")
        return ps


def parse(path):
    text = path.read_text(encoding="latin-1")
    p = Parser(tokenize(text), path)
    items = []  # ("func", name, ret, params, frame, next) | ("global"/"field"/"const", ...) | ("todo", text)
    while p.peek()[0] is not None:
        kind, v = p.peek()
        if kind == "directive":
            p.next()
            m = re.match(r"\s*#define\s+(\w+)(\(\))?\s*(.*)", v, re.S)
            if m and not m.group(2) and m.group(3).strip():
                items.append(("define", m.group(1), m.group(3).strip()))
            else:
                items.append(("todo", v.strip()))
            continue
        if kind == "frame":
            p.next()
            continue
        if v == ";":
            p.next()
            continue
        if v == "var":
            # `var struct {...} name[] = {...};`
            start = p.i
            while p.peek()[1] != ";":
                if p.peek()[1] == "{":
                    p.skip_balanced("{", "}")
                else:
                    p.next()
            p.next()
            items.append(("todo", " ".join(t[1] for t in p.t[start:p.i])[:200] + " ..."))
            continue
        field = False
        if v == ".":
            p.next()
            field = True
        ty = p.next()[1]
        if ty not in TY:
            raise SystemExit(f"{path}: unexpected `{ty}` at top level")
        is_func_type = p.peek()[1] == "("
        params = p.params() if is_func_type else None
        names = [p.next()[1]]
        while p.peek()[1] == ",":
            p.next()
            names.append(p.next()[1])
        if field:
            zt = "?Function" if is_func_type else TY[ty]
            for n in names:
                items.append(("field", n, zt, ty if not is_func_type else f"{ty}({', '.join(t + ' ' + n for t, n in params)})"))
            continue
        if is_func_type:
            (name,) = names
            if p.peek()[1] == ";":
                p.next()
                continue  # prototype
            p.expect("=")
            frame = nxt = None
            if p.peek()[1] == "[":
                inner = p.skip_balanced("[", "]")
                vals = [t[1] for t in inner if t[1] != ","]
                frame, nxt = vals[0], vals[1]
            if p.peek()[1] == "#":
                p.next()
                p.next()
                continue  # builtin
            p.skip_balanced("{", "}")
            items.append(("func", name, TY[ty], params, frame, nxt))
            continue
        if p.peek()[1] == "=":
            p.next()
            val = p.next()
            if val[1] == "-":
                val = (val[0], "-" + p.next()[1])
            (name,) = names
            items.append(("const", name, TY[ty], val))
            continue
        for n in names:
            items.append(("global", n, TY[ty]))
    return items


def frames_of(path):
    frames = []
    for line in path.read_text(encoding="latin-1").split("\n"):
        m = re.match(r"\s*\$frame\s+(.*)", line.split("//")[0])
        if m:
            frames += m.group(1).split()
    return frames


def main():
    args = [a for a in sys.argv[1:] if a != "--force"]
    force = "--force" in sys.argv
    src, out = map(pathlib.Path, args)
    files = []
    for line in (src / "progs.src").read_text().split("\n"):
        w = line.split("//")[0].split()
        if w and w[0].endswith(".qc"):
            files.append(w[0])
    files = [f for f in files if f not in ("defs.qc", "localized_text.qc")]

    parsed = {f: parse(src / f) for f in files}
    # Where each name lives (first definition wins, as in fteqcc).
    home = {}
    for f in files:
        for it in parsed[f]:
            if it[0] in ("func", "global", "field", "const", "define"):
                home.setdefault(it[1], f)

    def modname(f):
        return pathlib.Path(f).stem

    def import_path(from_f, to):
        depth = len(pathlib.Path(from_f).parts) - 1
        return "../" * depth + to

    for f in files:
        dest = out / (f[:-3] + ".zig")
        if dest.exists() and not force:
            raise SystemExit(f"{dest} exists; pass --force to overwrite")
        dest.parent.mkdir(parents=True, exist_ok=True)
        body, imports = [], {}
        seen_local = set()
        # Zig doesn't allow parameters to shadow file-level names: the
        # file's own declarations, and the modules it may import.
        file_names = RESERVED | {modname(g) for g in files} | {
            it[1] for it in parsed[f] if it[0] in ("func", "global", "field", "const", "define")}

        def pname(n):
            return ident(n + "_" if n in file_names else n)

        def ref(name):
            h = home.get(name)
            if h is None:
                raise SystemExit(f"{f}: `{name}` isn't defined anywhere")
            if h == f:
                return ident(name)
            m = modname(h)
            imports[m] = import_path(f, h[:-3] + ".zig")
            return f"{m}.{ident(name)}"

        for it in parsed[f]:
            kind = it[0]
            if kind in ("func", "global", "field", "const", "define"):
                if home[it[1]] != f or it[1] in seen_local:
                    body.append(f"// (`{it[1]}` is already declared in `{home[it[1]][:-3]}.zig`.)")
                    continue
                seen_local.add(it[1])
                if it[1] in RESERVED:
                    raise SystemExit(f"{f}: `{it[1]}` clashes with a generated name")
            if kind == "todo":
                body.append("// TODO(translate): " + it[1].replace("\n", "\n// "))
            elif kind == "define":
                _, n, v = it
                if v.startswith("'"):
                    body.append(f"pub const {ident(n)}: Vector = .{{ {', '.join(v.strip(chr(39)).split())} }};")
                elif v.startswith('"'):
                    body.append(f"pub const {ident(n)} = {v};")
                else:
                    body.append(f"pub const {ident(n)}: f32 = {v};")
            elif kind == "const":
                _, n, zt, (vk, v) = it
                if vk == "vector":
                    body.append(f"pub const {ident(n)}: Vector = .{{ {', '.join(v.strip(chr(39)).split())} }};")
                elif vk == "string":
                    body.append(f"pub const {ident(n)} = {v};")
                else:
                    body.append(f"pub const {ident(n)}: {zt} = {v};")
            elif kind == "global":
                _, n, zt = it
                body.append(f'pub const {ident(n)} = q.userGlobal({zt}, "{n}");')
            elif kind == "field":
                _, n, zt, qt = it
                if zt == "?Function" and qt != "void()":
                    body.append(f"/// `.{qt} {n}`; call with `q.callAs`.")
                body.append(f'pub const {ident(n)} = q.userField({zt}, "{n}");')
            elif kind == "func":
                _, n, ret, params, frame, nxt = it
                ps = ", ".join(f"{pname(pn)}: {pt}" for pt, pn in params)
                body.append(f"pub export fn {ident(n)}({ps}) {ret} {{")
                if frame is not None:
                    if frame.startswith("$"):
                        body.append(f"    state(.{frame[1:]}, {ref(nxt)});")
                    else:
                        # A literal frame number (e.g. weapon model frames).
                        body.append(f"    q.setState({frame}, q.func({ref(nxt)}));")
                for _, pn in params:
                    body.append(f"    _ = {pname(pn)};")
                body.append("    // TODO(translate)")
                body.append("    unreachable;")
                body.append("}")
            body.append("")

        lines = [f"//! {f}", "", f'const q = @import("{import_path(f, "defs.zig")}");',
                 f'const lq = @import("{import_path(f, "lq.zig")}");',
                 f'const loc = @import("{import_path(f, "localized_text.zig")}");',
                 "const S = q.S;", "const Entity = q.Entity;", "const Function = q.Function;",
                 "const String = q.String;", "const Vector = q.Vector;"]
        for m, path in sorted(imports.items()):
            lines.append(f'const {m} = @import("{path}");')
        lines.append("")
        frames = frames_of(src / f)
        if frames:
            lines.append("/// The `$frame` macros, numbered from 0 in declaration order.")
            lines.append("const Frame = enum(u8) {")
            lines += [f"    {ident(fr)}," for fr in frames]
            lines += ["};", "",
                      "/// `$frame`, as a float.",
                      "inline fn fr(comptime frame: Frame) f32 {",
                      "    return @floatFromInt(@backingInt(frame));",
                      "}", "",
                      "/// The `[$frame, next]` prefix of a state function.",
                      "inline fn state(comptime frame: Frame, comptime next: anytype) void {",
                      "    q.setState(fr(frame), q.func(next));",
                      "}", ""]
        dest.write_text("\n".join(lines + body).rstrip() + "\n")
        print(dest)

    root = out / "root.zig"
    if root.exists() and not force and "hello from" not in root.read_text():
        raise SystemExit(f"{root} exists; pass --force to overwrite")
    mods = ["defs.zig", "lq.zig", "localized_text.zig"] + [f[:-3] + ".zig" for f in files]
    root.write_text(
        "//! progs.src: every file of LibreQuake's NetQuake game code, in the\n"
        "//! original order. Their exported functions make up the progs.\n\n"
        "const defs = @import(\"defs.zig\");\n\n"
        "const files = .{\n" + "".join(f'    @import("{m}"),\n' for m in mods) + "};\n\n"
        "comptime {\n"
        "    // Every QuakeC global and field exists in the progs, used or not.\n"
        "    for (files) |f| defs.declareUserDefs(f);\n"
        "}\n\n"
        "test {\n    inline for (files) |f| _ = f;\n}\n")
    print(root)


if __name__ == "__main__":
    main()
