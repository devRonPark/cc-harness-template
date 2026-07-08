#!/usr/bin/env python3
"""Shared helpers for JSON-backed harness task state."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any


STATUSES = {"todo", "wip", "done", "blocked"}
STATUS_LABELS = {
    "todo": "cc:TODO",
    "wip": "cc:WIP",
    "done": "cc:완료",
    "blocked": "cc:BLOCKED",
}
REVERSE_STATUS_LABELS = {v: k for k, v in STATUS_LABELS.items()}
TASK_ID_RE = re.compile(r"^[0-9]+\.[0-9]+(\.[0-9]+)?$")
BRANCH_TASK_RE = re.compile(r"^task/([0-9]+\.[0-9]+(\.[0-9]+)?)-")


class TaskError(Exception):
    """Validation or task-state error."""


@dataclass(frozen=True)
class Task:
    id: str
    title: str
    dod: str
    acceptance: str
    depends: list[str]
    status: str
    gh: str
    section: str
    blocked_reason: str = ""

    @classmethod
    def from_dict(cls, raw: dict[str, Any], index: int) -> "Task":
        required = ["id", "title", "dod", "acceptance", "depends", "status", "gh"]
        missing = [key for key in required if key not in raw]
        if missing:
            raise TaskError(f"task[{index}] missing required keys: {', '.join(missing)}")

        depends = raw["depends"]
        if isinstance(depends, str):
            depends = [] if depends.strip() in {"", "-"} else [part.strip() for part in depends.split(",")]
        if not isinstance(depends, list) or not all(isinstance(dep, str) for dep in depends):
            raise TaskError(f"task[{index}] depends must be a list of task ids")

        return cls(
            id=str(raw["id"]).strip(),
            title=str(raw["title"]).strip(),
            dod=str(raw["dod"]).strip(),
            acceptance=str(raw["acceptance"]).strip(),
            depends=[dep.strip() for dep in depends if dep.strip()],
            status=str(raw["status"]).strip(),
            gh=str(raw["gh"]).strip() or "-",
            section=str(raw.get("section", "Tasks")).strip() or "Tasks",
            blocked_reason=str(raw.get("blocked_reason", "")).strip(),
        )

    def to_dict(self) -> dict[str, Any]:
        data: dict[str, Any] = {
            "id": self.id,
            "title": self.title,
            "dod": self.dod,
            "acceptance": self.acceptance,
            "depends": self.depends,
            "status": self.status,
            "gh": self.gh,
            "section": self.section,
        }
        if self.blocked_reason:
            data["blocked_reason"] = self.blocked_reason
        return data


def root_path(value: str | None) -> Path:
    return Path(value or ".").resolve()


def tasks_path(root: Path) -> Path:
    return root / "tasks" / "index.json"


def plans_path(root: Path) -> Path:
    return root / "Plans.md"


def load_task_document(root: Path) -> dict[str, Any]:
    path = tasks_path(root)
    if not path.exists():
        raise TaskError(f"{path} not found")
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise TaskError(f"{path}: invalid JSON at line {exc.lineno}: {exc.msg}") from exc
    if not isinstance(data, dict):
        raise TaskError("tasks/index.json root must be an object")
    if not isinstance(data.get("tasks"), list):
        raise TaskError("tasks/index.json must contain a tasks array")
    return data


def load_tasks(root: Path) -> list[Task]:
    document = load_task_document(root)
    tasks: list[Task] = []
    for index, raw in enumerate(document["tasks"]):
        if not isinstance(raw, dict):
            raise TaskError(f"task[{index}] must be an object")
        tasks.append(Task.from_dict(raw, index))
    return tasks


def validate_tasks(tasks: list[Task]) -> list[str]:
    errors: list[str] = []
    seen: set[str] = set()
    by_id: dict[str, Task] = {}

    for task in tasks:
        if not TASK_ID_RE.match(task.id):
            errors.append(f"{task.id or '(empty)'}: invalid task id")
        if task.id in seen:
            errors.append(f"{task.id}: duplicate task id")
        seen.add(task.id)
        by_id[task.id] = task

        if not task.title:
            errors.append(f"{task.id}: title is required")
        if not task.dod:
            errors.append(f"{task.id}: dod is required")
        if task.status not in STATUSES:
            errors.append(f"{task.id}: invalid status '{task.status}'")
        if task.status == "wip" and not task.acceptance:
            errors.append(f"{task.id}: wip task requires acceptance ('-' if intentionally skipped)")
        if task.status == "blocked" and not task.blocked_reason:
            errors.append(f"{task.id}: blocked task requires blocked_reason")

    for task in tasks:
        for dep in task.depends:
            if dep not in by_id:
                errors.append(f"{task.id}: depends on missing task {dep}")
            elif task.status == "wip" and by_id[dep].status != "done":
                errors.append(f"{task.id}: depends on {dep}, but it is {by_id[dep].status}")

    return errors


def ensure_valid_tasks(root: Path) -> list[Task]:
    tasks = load_tasks(root)
    errors = validate_tasks(tasks)
    if errors:
        raise TaskError("\n".join(errors))
    return tasks


def markdown_cell(value: str) -> str:
    text = value.replace("\n", " ").strip()
    return text.replace("|", r"\|")


def depends_cell(task: Task) -> str:
    return ", ".join(task.depends) if task.depends else "-"


def render_plans(root: Path, tasks: list[Task]) -> str:
    header = [
        "# Plans.md — [PROJECT_NAME]",
        "",
        "작성일: YYYY-MM-DD",
        "기준 문서: docs/PRD.md",
        "",
        "---",
        "",
    ]
    lines = header[:]
    current_section: str | None = None

    for task in tasks:
        if task.section != current_section:
            if current_section is not None:
                lines.extend(["", "---", ""])
            current_section = task.section
            lines.extend(
                [
                    f"## {current_section}",
                    "",
                    "| Task | 내용 | DoD | Acceptance | Depends | Status | GH |",
                    "|------|------|-----|------------|---------|--------|----|",
                ]
            )

        lines.append(
            "| "
            + " | ".join(
                [
                    markdown_cell(task.id),
                    markdown_cell(task.title),
                    markdown_cell(task.dod),
                    markdown_cell(task.acceptance or "-"),
                    markdown_cell(depends_cell(task)),
                    markdown_cell(STATUS_LABELS[task.status]),
                    markdown_cell(task.gh or "-"),
                ]
            )
            + " |"
        )

    lines.extend(
        [
            "",
            "---",
            "",
            "<!--",
            "Task 상태의 단일 출처는 tasks/index.json이다.",
            "Plans.md의 Task 표와 Status 컬럼은 직접 편집하지 말고 tasks/index.json을 수정한 뒤",
            "python3 scripts/sync_plans.py를 실행한다. CI에서는 scripts/validate_tasks.py가",
            "tasks/index.json을 검증하고, --check로 Plans.md 동기화 여부를 확인한다.",
            "",
            "JSON status 값:",
            "  todo    — 미시작 (Plans.md 표시: cc:TODO)",
            "  wip     — 진행 중 (Plans.md 표시: cc:WIP)",
            "  done    — 완료 (Plans.md 표시: cc:완료)",
            "  blocked — 차단됨 (Plans.md 표시: cc:BLOCKED, blocked_reason 필수)",
            "",
            "GH 컬럼:",
            "  -         — GitHub 미연동 또는 이슈 미생성",
            "  #N        — 연결된 GitHub Issue 번호 (harness-plan이 자동 기입)",
            "",
            "Acceptance 컬럼:",
            '  -         — 기계 검증 없음 (skip). "|| echo skip"처럼 항상 성공하는',
            "              패턴은 oracle을 무력화하므로 금지 — 검증 안 할 거면 \"-\"로 명시.",
            "  명령어     — PR 오픈 시 plans-guard CI가 실행, 실패하면 PR 차단.",
            "              CI checkout 범위 밖 경로(예: ../다른-repo/)는 실행 불가 — 금지.",
            "  예시: pytest tests/test_auth.py -k login",
            "  예시: curl -sf http://localhost/health | grep '\"status\":\"ok\"'",
            "  패턴별 예시:",
            "    파일 존재: test -f src/main.py",
            "    명령 성공: npm run build 2>&1 | grep -v error",
            "    HTTP 응답: curl -sf http://localhost:3000/health | grep ok",
            "    테스트 통과: pytest tests/ -x -q",
            "    출력 포함: go test ./... | grep -v SKIP",
            "  escaped pipe(예: grep 'a\\|b')는 Acceptance 컬럼에서만 사용 — DoD 등 다른",
            "  컬럼에 쓰면 파서가 열 개수를 오인식한다.",
            "  * 스택 설치(npm ci 등)는 .github/workflows/plans-guard.yml 상단 주석 해제",
            "",
            "DoD (Definition of Done) 작성 원칙:",
            "  - 검증 가능한 파일·명령·출력으로 기술",
            "  - \"존재한다\", \"성공한다\", \"에러 0\"처럼 객관적 기준",
            "  - \"잘 작성된다\", \"좋다\"처럼 주관적 기준 금지",
            "-->",
            "",
        ]
    )
    return "\n".join(lines)


def write_task_document(root: Path, tasks: list[Task], document: dict[str, Any] | None = None) -> None:
    path = tasks_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)
    output = dict(document or {})
    output["tasks"] = [task.to_dict() for task in tasks]
    path.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def add_common_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--root", default=".", help="repository root (default: current directory)")
