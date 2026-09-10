#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "MANIFEST.sha256"
INVENTORY = ROOT / "REPOSITORY_INVENTORY.json"


def tracked_paths() -> list[str]:
    out = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT)
    return sorted(p.decode("utf-8") for p in out.split(b"\0") if p)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


tracked = tracked_paths()
base_paths = [p for p in tracked if p not in {"MANIFEST.sha256", "REPOSITORY_INVENTORY.json"}]
existing_base = [p for p in base_paths if (ROOT / p).is_file()]

counts: Counter[str] = Counter()
total_bytes = 0
for rel in existing_base:
    path = ROOT / rel
    total_bytes += path.stat().st_size
    suffix = path.suffix.lower() if path.suffix else "[no_extension]"
    counts[suffix] += 1

questions = json.loads((ROOT / "data/questions.json").read_text(encoding="utf-8"))
flow = json.loads((ROOT / "data/story_flow.json").read_text(encoding="utf-8"))

inventory = {
    "project": "ZooQuest: A Jornada do Aprendizado",
    "state": "GOVERNED_REPOSITORY_RUNTIME_GATED",
    "godot_version": "4.7.2",
    "file_count_excluding_manifest_inventory": len(existing_base),
    "total_bytes_excluding_manifest_inventory": total_bytes,
    "counts_by_extension": dict(sorted(counts.items())),
    "godot_scenes": counts.get(".tscn", 0),
    "gdscript_files": counts.get(".gd", 0),
    "questions": sum(len(questions.get(phase, [])) for phase in ("frog", "bird", "worm")),
    "flow_steps": len(flow),
    "minigames": ["frog", "bird", "worm"],
    "static_validation": "ENFORCED_BY_PRE_PR_AND_CI",
    "runtime_validation": "ENFORCED_BY_GITHUB_ACTIONS_GODOT_4_7_2",
    "required_checks": ["branch-policy", "repository-audit", "godot-tests"],
    "manifest_contract": "SHA256 of all tracked regular files except MANIFEST.sha256; includes REPOSITORY_INVENTORY.json",
    "metadata_generator": "scripts/update_repository_metadata.py",
}
INVENTORY.write_text(json.dumps(inventory, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

manifest_paths = [p for p in tracked if p != "MANIFEST.sha256" and (ROOT / p).is_file()]
# REPOSITORY_INVENTORY foi reescrito acima, portanto seu hash agora e canonico.
lines = [f"{sha256(ROOT / rel)}  ./{rel}" for rel in sorted(manifest_paths)]
MANIFEST.write_text("\n".join(lines) + "\n", encoding="utf-8")

print("ZOOQUEST_REPOSITORY_METADATA=UPDATED")
print(f"INVENTORY_FILES={len(existing_base)}")
print(f"MANIFEST_ENTRIES={len(manifest_paths)}")
