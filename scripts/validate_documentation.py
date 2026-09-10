#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
checks = 0


def check(condition: bool, message: str) -> None:
    global checks
    checks += 1
    if not condition:
        errors.append(message)


def tracked_paths() -> list[str]:
    output = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT)
    return sorted(item.decode("utf-8") for item in output.split(b"\0") if item)


tracked = tracked_paths()
tracked_set = set(tracked)

canonical_top_docs = {
    "README.md",
    "ARQUITETURA.md",
    "STATUS_DO_PROJETO.md",
    "QUALIDADE_E_TESTES.md",
    "GUIA_DO_CODIGO.md",
    "GOVERNANCA_GITHUB.md",
    "ROADMAP.md",
    "REQUISITOS_E_RASTREABILIDADE.md",
    "RESPONSABILIDADES.md",
    "CHECKLIST_ENTREGA.md",
    "ROTEIRO_DEMONSTRACAO.md",
}
actual_top_docs = {
    Path(rel).name
    for rel in tracked
    if Path(rel).parent == Path("docs") and Path(rel).suffix == ".md"
}
check(actual_top_docs == canonical_top_docs, f"documentos em docs/ fora do padrão: {sorted(actual_top_docs ^ canonical_top_docs)}")

for name in canonical_top_docs:
    path = ROOT / "docs" / name
    check(path.is_file(), f"documento canônico ausente: docs/{name}")

reference_index = "docs/referencias/README.md"
check(reference_index in tracked_set and (ROOT / reference_index).is_file(), "índice de referências ausente")

root_markdown = {rel for rel in tracked if "/" not in rel and rel.endswith(".md")}
check(root_markdown == {"README.md", "CONTRIBUTING.md"}, f"Markdown inesperado na raiz: {sorted(root_markdown)}")
root_text = {rel for rel in tracked if "/" not in rel and rel.endswith(".txt")}
check(not root_text, f"arquivo TXT operacional na raiz: {sorted(root_text)}")

historical_validation = [rel for rel in tracked if rel.startswith("validation/")]
check(
    not historical_validation,
    "saídas de validação históricas não devem ser versionadas: " + ", ".join(historical_validation),
)
for redundant in ("MANIFEST.sha256", "REPOSITORY_INVENTORY.json"):
    check(redundant not in tracked_set, f"metadado redundante ainda versionado: {redundant}")

for rel in tracked:
    item = Path(rel)
    if item.parent == Path("docs") and item.suffix == ".md" and item.name != "README.md":
        check(bool(re.fullmatch(r"[A-Z0-9_]+\.md", item.name)), f"nome fora do padrão em docs/: {rel}")

text_files: list[Path] = []
for rel in tracked:
    file_path = ROOT / rel
    if rel.startswith("docs/referencias/") and rel != reference_index:
        continue
    if rel.startswith("docs/relatorio/"):
        continue
    if file_path.suffix.lower() in {".md", ".txt"} or rel == ".github/CODEOWNERS":
        text_files.append(file_path)

placeholder_patterns = [
    r"\bTODO\b",
    r"\bTBD\b",
    r"\bFIXME\b",
    r"\bURL_[A-Z_]{3,}\b",
    r"ponto de retomada",
    r"ambiente de gera[cç][aã]o",
    r"\bChatGPT\b",
    r"\bOpenAI\b",
]
for file_path in text_files:
    content = file_path.read_text(encoding="utf-8", errors="replace")
    for pattern in placeholder_patterns:
        check(not re.search(pattern, content, re.IGNORECASE), f"placeholder ou texto operacional em {file_path.relative_to(ROOT)}: {pattern}")

pr_template = (ROOT / ".github/pull_request_template.md").read_text(encoding="utf-8")
check("\n1.\n2.\n3.\n" not in pr_template, "template de PR contém passos vazios")
check("..." not in pr_template, "template de PR contém reticências como placeholder")

codeowners = (ROOT / ".github/CODEOWNERS").read_text(encoding="utf-8")
check("@PedroZaupaUni" in codeowners, "CODEOWNERS sem mantenedor geral")
check("@danielyassuo" in codeowners, "CODEOWNERS sem responsável compartilhado de gameplay")
check("quando definidos" not in codeowners.lower(), "CODEOWNERS contém instrução pendente")
check("adicione" not in codeowners.lower(), "CODEOWNERS contém instrução de preenchimento")

readme = (ROOT / "README.md").read_text(encoding="utf-8")
for required_link in ("docs/README.md", "docs/QUALIDADE_E_TESTES.md", "CONTRIBUTING.md", "docs/referencias/"):
    check(required_link in readme, f"README sem referência canônica: {required_link}")

docs_index = (ROOT / "docs/README.md").read_text(encoding="utf-8")
for name in sorted(canonical_top_docs - {"README.md"}):
    check(name in docs_index, f"índice de documentação não referencia {name}")

status = "PASS" if not errors else "FAIL"
print("ZOOQUEST_DOCUMENTATION_VALIDATION=" + status)
print(f"CHECKS_TOTAL={checks}")
print(f"ERRORS={len(errors)}")
for error in errors:
    print("ERROR " + error)
sys.exit(1 if errors else 0)
