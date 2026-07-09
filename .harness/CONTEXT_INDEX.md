# CONTEXT_INDEX.md — 파일 역할 인덱스

> 루트 `.harness/*.md`는 템플릿이고, 실제 작업 맥락은 `.harness/tasks/<task-key>/`에 있다.

## 세션 재개 읽는 순서

1. `tasks/index.json`에서 `wip` Task 또는 사용자가 지정한 Task를 확인한다.
2. 해당 Task의 `.harness/tasks/<task-key>/STATE.md`를 읽는다.
3. 있으면 `.harness/tasks/<task-key>/RUN_REPORT.md`를 읽는다.
4. `.harness/LESSONS.md` 최근 항목을 읽는다.
5. `Plans.md`를 확인한다.
6. 아래 표에서 필요한 추가 문서만 고른다.

## Task별 맥락

- `.harness/tasks/<task-key>/STATE.md`: 현재 스냅샷
- `.harness/tasks/<task-key>/LOG.md`: 작업·에러 원문
- `.harness/tasks/<task-key>/RUN_REPORT.md`: 변경·결정·검증 요약
- `.harness/tasks/<task-key>/{HANDOFF,TASKS,CHECKPOINTS}.md`: 필요할 때만 읽는 보조 기록
- `.harness/tasks/<task-key>/tasks.index.snapshot.json`: 시작 시점 비교가 필요할 때만 읽는 참고본

## 기본 파일

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `CLAUDE.md` | 프로젝트 규칙 | 규칙 확인 시 |
| `AGENTS.md` | Codex 진입점 | Codex 절차 확인 시 |
| `tasks/index.json` | Task 상태 단일 출처 | 항상 먼저 |
| `Plans.md` | 사람이 읽는 Task snapshot | 진행 상황 확인 시 |
| `.harness/{STATE,HANDOFF,TASKS,LOG,CHECKPOINTS,RUN_REPORT}.md` | 새 Task용 템플릿 | Task 디렉토리 생성 시 |
| `.harness/LESSONS.md` | 전역 재발 방지 기록 | 세션 재개·반복 오류 확인 시 |
| `.harness/events/planning.jsonl` | planning 실패·반영 흐름 추적 | planning 문제 조사 시 |
| `.harness/shared/planning/runs/` | planning run 작업대 | 특정 run 감사 시 |

## 필요할 때만

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `.agents/skills/` | Codex repo-scoped skills | Codex skill 절차 수정 시 |
| `.claude/commands/` | Claude Code local commands | Claude command 절차 수정 시 |
| `agents/quality-gates.md` | scope·YAGNI·review·reporting 게이트 | 구현·리뷰 전 |
| `agents/task-decomposer.md` | Task 세분화 기준 | 계획·구현 게이트 확인 시 |
| `agents/test-agent.md` | 런타임 검증 절차 | worker 완료 후 |
| `.github/workflows/` | CI와 plans guard | CI 수정 시 |
| `init.sh` | 새 프로젝트 복사 스크립트 | 템플릿 적용 방식 수정 시 |
| `templates/skeleton/` | init.sh가 복사하는 초기 골격 | 골격 자체 수정 시 |
| `docs/templates/` | 기획 문서 골격 | 새 기획 착수 시 |
| `docs/github-integration.md` | GitHub 연동 상세 | GitHub 연동 설정 시 |
| `docs/specs/` | 현재 Acceptance가 참조하는 감사·품질 gate 배경 | 배경 확인이 필요할 때 |
| `BLUEPRINT.md` | 시스템 구조 설명 | 구조 이해가 필요할 때 |
