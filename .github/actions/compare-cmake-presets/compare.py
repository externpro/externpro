import difflib
import argparse
import json
import os
import subprocess
import sys

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def read_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def write_json(path: str, obj) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2)
        f.write("\n")

def norm_includes(obj) -> list[str]:
    inc = obj.get("include", [])
    if not isinstance(inc, list):
        return []
    return [v for v in inc if isinstance(v, str)]

def normalize_repo_includes(includes: list[str]) -> list[str]:
    out: list[str] = []
    for inc in includes:
        if inc == ".devcontainer/cmake/presets/xpWindowsVs2022.json":
            out.append(".devcontainer/cmake/presets/xpMswVs2022.json")
            out.append(".devcontainer/cmake/presets/xpMswVs2026.json")
            continue
        out.append(inc)
    return out

def strip_top_level_include(obj):
    if not isinstance(obj, dict):
        return obj
    copy = dict(obj)
    copy.pop("include", None)
    return copy

def apply_windows_vs2022_include_fix(repo_presets: str) -> bool:
    repo_json = read_json(repo_presets)
    if not isinstance(repo_json, dict):
        return False

    includes = repo_json.get("include", [])
    if not isinstance(includes, list):
        return False

    changed = False
    out: list[str] = []
    for v in includes:
        if not isinstance(v, str):
            out.append(v)
            continue
        if v == ".devcontainer/cmake/presets/xpWindowsVs2022.json":
            out.append(".devcontainer/cmake/presets/xpMswVs2022.json")
            out.append(".devcontainer/cmake/presets/xpMswVs2026.json")
            changed = True
            continue
        out.append(v)

    if not changed:
        return False

    repo_json["include"] = out
    write_json(repo_presets, repo_json)
    return True

def stage_file(path: str) -> None:
    subprocess.run(["git", "add", path], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def build_report(repo_presets: str, template_presets: str, *, fix: bool, stage: bool) -> str:
    lines: list[str] = []

    if not os.path.exists(template_presets):
        lines.append(f"- Template presets missing: {template_presets}")
        return "\n".join(lines)

    if not os.path.exists(repo_presets):
        lines.append(f"- Repo is missing {repo_presets}")
        return "\n".join(lines)

    fixed = False
    if fix:
        fixed = apply_windows_vs2022_include_fix(repo_presets)
        if fixed and stage:
            stage_file(repo_presets)

    repo_txt = read_text(repo_presets)
    tmpl_txt = read_text(template_presets)

    if repo_txt == tmpl_txt:
        if fixed:
            if stage:
                lines.append(
                    "- Auto-fix: replaced `.devcontainer/cmake/presets/xpWindowsVs2022.json` include and staged `CMakePresets.json`"
                )
            else:
                lines.append(
                    "- Auto-fix: replaced `.devcontainer/cmake/presets/xpWindowsVs2022.json` include"
                )
            return "\n".join(lines)
        return ""

    repo_json = read_json(repo_presets)
    tmpl_json = read_json(template_presets)

    repo_inc_raw = norm_includes(repo_json)
    repo_inc = normalize_repo_includes(repo_inc_raw)
    tmpl_inc = norm_includes(tmpl_json)

    has_legacy_windows_vs2022 = any(
        x == ".devcontainer/cmake/presets/xpWindowsVs2022.json" for x in repo_inc_raw
    )

    repo_set = set(repo_inc_raw)
    tmpl_set = set(tmpl_inc)

    missing = sorted(tmpl_set - repo_set)
    extra = sorted(repo_set - tmpl_set)

    outside_include_diff = strip_top_level_include(repo_json) != strip_top_level_include(tmpl_json)

    lines.append("- Repo `CMakePresets.json` differs from template")

    if fixed:
        if stage:
            lines.append(
                "- Auto-fix: replaced `.devcontainer/cmake/presets/xpWindowsVs2022.json` include and staged `CMakePresets.json`"
            )
        else:
            lines.append(
                "- Auto-fix: replaced `.devcontainer/cmake/presets/xpWindowsVs2022.json` include"
            )

    if missing or extra:
        if len(repo_inc) == 1:
            lines.append(f"- Info: repo includes only one preset ({repo_inc[0]})")

        if missing:
            lines.append("- Missing includes (present in template):")
            for m in missing:
                lines.append(f"  - {m}")

        if extra:
            lines.append("- Extra includes (present in repo only):")
            for e in extra:
                lines.append(f"  - {e}")

        if has_legacy_windows_vs2022:
            lines.append(
                "- Action: replace `.devcontainer/cmake/presets/xpWindowsVs2022.json` with:"
            )
            lines.append('    ".devcontainer/cmake/presets/xpMswVs2022.json",')
            lines.append('    ".devcontainer/cmake/presets/xpMswVs2026.json"')

        if (
            not has_legacy_windows_vs2022
            and not any("xpMswVs2026.json" in x for x in repo_inc)
            and any("xpMswVs2026.json" in x for x in tmpl_inc)
        ):
            lines.append("- Action: consider adding `xpMswVs2026.json` (Visual Studio 2026)")

        if any("Targets.json" in x for x in extra):
            lines.append(
                "- Info: repo uses a `*Targets.json` preset include (may be intentional for specialized repos)"
            )
    else:
        lines.append("- Diff is not in the `include` list (review other fields)")

    if (missing or extra) and outside_include_diff:
        lines.append("- Note: there are also diffs outside the `include` section")

    return "\n".join(lines)

def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--fix", action="store_true")
    parser.add_argument("--stage", action="store_true")
    parser.add_argument("repo_presets", nargs="?")
    parser.add_argument("template_presets", nargs="?")
    args = parser.parse_args(argv[1:])

    if not args.repo_presets or not args.template_presets:
        print(
            "Usage: compare.py [--fix] [--stage] <repo_presets> <template_presets>",
            file=sys.stderr,
        )
        return 2

    report = build_report(args.repo_presets, args.template_presets, fix=args.fix, stage=args.stage)
    if report:
        print(report)
    return 0

if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
