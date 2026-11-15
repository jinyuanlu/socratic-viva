#!/usr/bin/env python3
"""Repository invariants. Prints each violation; exit status 1 if any."""
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLUGIN = ROOT / "plugins" / "viva"
VENDORED = PLUGIN / "vendor" / "socratic-tutor" / "SKILL.md"
VENDORED_BLOB = "93bb7befeb73c41b4354175f9ef765547d4f3506"
MANIFESTS = [PLUGIN / ".claude-plugin" / "plugin.json", PLUGIN / ".codex-plugin" / "plugin.json"]
MARKETPLACES = [ROOT / ".claude-plugin" / "marketplace.json", ROOT / ".agents" / "plugins" / "marketplace.json"]
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)


def rel(path):
    return path.relative_to(ROOT).as_posix()


def git_blob_sha(path):
    data = path.read_bytes()
    return hashlib.sha1(b"blob %d\0" % len(data) + data).hexdigest()


def manifest_errors():
    plugins = [json.loads(p.read_text(encoding="utf-8")) for p in MANIFESTS]
    listed = [e["name"] for p in MARKETPLACES for e in json.loads(p.read_text(encoding="utf-8"))["plugins"]]
    names = {m["name"] for m in plugins} | set(listed)
    versions = {m["version"] for m in plugins}
    return ([f"plugin names disagree: {sorted(names)}"] if len(names) != 1 else []) + (
        [f"plugin versions disagree: {sorted(versions)}"] if len(versions) != 1 else [])


def skill_errors(skill_md):
    match = FRONTMATTER.match(skill_md.read_text(encoding="utf-8"))
    fields = dict(re.findall(r"^([\w-]+):\s*(.*)$", match.group(1), re.M)) if match else {}
    name = fields.get("name", "").strip('"')
    return ([] if match else [f"{rel(skill_md)}: no frontmatter"]) + (
        [] if name == skill_md.parent.name else [f"{rel(skill_md)}: name {name!r} is not the folder name"]) + (
        [] if fields.get("description") else [f"{rel(skill_md)}: no description"])


def link_errors(md):
    targets = (t.split("#")[0] for t in LINK.findall(md.read_text(encoding="utf-8")))
    local = (t for t in targets if t and not re.match(r"[a-z][a-z0-9+.-]*:", t))
    return [f"{rel(md)}: broken link {t}" for t in local if not (md.parent / t).exists()]


def agent_errors(agent_md):
    match = FRONTMATTER.match(agent_md.read_text(encoding="utf-8"))
    fields = dict(re.findall(r"^([\w-]+):\s*(.*)$", match.group(1), re.M)) if match else {}
    return ([] if fields.get("name") == agent_md.stem else [f"{rel(agent_md)}: name is not the file name"]) + (
        [] if fields.get("description") else [f"{rel(agent_md)}: no description"])


def hook_errors():
    hooks = json.loads((PLUGIN / "hooks" / "hooks.json").read_text(encoding="utf-8"))["hooks"]
    commands = [h["command"] for entries in hooks.values() for e in entries for h in e["hooks"]]
    scripts = [m for c in commands for m in re.findall(r"\$\{CLAUDE_PLUGIN_ROOT\}/([\w./-]+)", c)]
    return [f"hooks.json: missing script {s}" for s in scripts if not (PLUGIN / s).is_file()]


def vendor_errors():
    actual = git_blob_sha(VENDORED)
    return [] if actual == VENDORED_BLOB else [f"{rel(VENDORED)}: blob {actual}, expected {VENDORED_BLOB}"]


def main():
    skills = sorted(PLUGIN.glob("skills/*/SKILL.md"))
    docs = sorted(p for p in ROOT.rglob("*.md") if ".git" not in p.parts and p != VENDORED)
    agents = sorted(PLUGIN.glob("agents/*.md"))
    errors = (manifest_errors() + vendor_errors() + hook_errors()
              + [e for a in agents for e in agent_errors(a)]
              + ([] if skills else ["no skills found"])
              + [e for s in skills for e in skill_errors(s)]
              + [e for d in docs for e in link_errors(d)])
    print("\n".join(errors) if errors else f"ok: {len(skills)} skills, {len(docs)} documents")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
