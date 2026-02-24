import difflib
import json
import os
import sys

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def read_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def norm_includes(obj) -> list[str]:
    inc = obj.get("include", [])
    if not isinstance(inc, list):
        return []
    return [v for v in inc if isinstance(v, str)]

def strip_top_level_include(obj):
    if not isinstance(obj, dict):
        return obj
    copy = dict(obj)
    copy.pop("include", None)
    return copy

def build_report(repo_presets: str, template_presets: str) -> str:
    lines: list[str] = []

    if not os.path.exists(template_presets):
        lines.append(f"- Template presets missing: {template_presets}")
        return "\n".join(lines)

    if not os.path.exists(repo_presets):
        lines.append(f"- Repo is missing {repo_presets}")
        return "\n".join(lines)

    repo_txt = read_text(repo_presets)
    tmpl_txt = read_text(template_presets)

    if repo_txt == tmpl_txt:
        return ""

    repo_json = read_json(repo_presets)
    tmpl_json = read_json(template_presets)

    repo_inc = norm_includes(repo_json)
    tmpl_inc = norm_includes(tmpl_json)

    repo_set = set(repo_inc)
    tmpl_set = set(tmpl_inc)

    missing = sorted(tmpl_set - repo_set)
    extra = sorted(repo_set - tmpl_set)

    outside_include_diff = strip_top_level_include(repo_json) != strip_top_level_include(tmpl_json)

    lines.append("- Repo `CMakePresets.json` differs from template")

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

        if any("xpWindowsVs2022.json" in x for x in repo_inc) and any(
            "xpMswVs2022.json" in x for x in tmpl_inc
        ):
            lines.append("- Action: rename `xpWindowsVs2022.json` to `xpMswVs2022.json`")

        if not any("xpMswVs2026.json" in x for x in repo_inc) and any(
            "xpMswVs2026.json" in x for x in tmpl_inc
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
    if len(argv) != 3:
        print("Usage: compare.py <repo_presets> <template_presets>", file=sys.stderr)
        return 2

    report = build_report(argv[1], argv[2])
    if report:
        print(report)
    return 0

if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
