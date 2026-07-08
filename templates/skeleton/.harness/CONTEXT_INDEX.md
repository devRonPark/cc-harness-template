# CONTEXT_INDEX.md — 파일 역할 인덱스

> 토큰 절약용. 세션 재개 시 이 인덱스로 "이번 작업에 필요한 파일"만 골라 읽는다.
> 새 파일을 만들거나 기존 파일의 역할이 바뀌면 여기를 갱신한다.

## 항상 먼저 (세션 재개 시)

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `.harness/STATE.md` | 현재 상태 스냅샷 | 매 세션 시작 |
| `.harness/LESSONS.md` | 재발 방지 기록 (최근 5개만) | 매 세션 시작 |
| `Plans.md` | Task 상태 단일 출처 (DoD·Acceptance·Status) | 매 세션 시작 |

## 필요할 때만

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `.harness/HANDOFF.md` | 직전 세션 인수인계 | 재개 직후 1회 |
| `.harness/TASKS.md` | 현재 Task의 세션 체크리스트 | Task 진행 중 |
| `.harness/LOG.md` | 작업·에러 로그 | 에러 이력 조회 시 |
| `.harness/CHECKPOINTS.md` | 작업 단위 완료 기록 | 이력 추적 시 |
| `.harness/events/planning.jsonl` | `/harness-plan` 단계별 감시 로그 (사용자 친화 JSONL) | planning 실패·반영 흐름 추적 시 |
| `.harness/shared/planning/latest.json` | 최신 planning run의 context/proposal/report 위치 | 최신 task-decomposer proposal 확인 시 |
| `.harness/shared/planning/runs/` | run별 context.json·proposed-tasks.json·decomposition-report.md 작업대 | 특정 planning run 감사 시 |
| `CLAUDE.md` | 프로젝트 규칙 (기획·구현·테스트·리뷰·상태 문서) | 규칙 확인 시 |
| `AGENTS.md` | Codex 진입점. CLAUDE.md 규칙을 Codex 세션에서 동일 절차로 실행하기 위한 호환 지침 | Codex 환경 구성·규칙 확인 시 |
| `.agents/skills/` | Codex repo-scoped skills (`$grill-me`, `$harness-plan`, `$harness-work`, `$harness-review`, `$harness-progress`, `$harness-sync`, `$branch-checkout`, `$git-push`, `$pr-create`) | Codex skill 호출 UX·절차 수정 시 |
| `.claude/commands/` | Claude Code local custom commands (`/branch-checkout`, `/git-push`, `/pr-create`) | Claude command 호출 UX·절차 수정 시 |
| `harness.toml` | harness 플러그인 설정 ([plan]·[test]·[review]) | 설정 변경 시 |
| `BLUEPRINT.md` | 시스템 전체 아키텍처 설명 (읽기용) | 구조 이해 필요 시 |
| `README.md` | 템플릿 사용법 (외부 사용자용) | 문서 갱신 시 |
| `agents/quality-gates.md` | Claude/Codex 공통 scope·YAGNI·review·reporting 게이트. ponytail/caveman 원칙을 repo 규칙으로 적용 | 구현·리뷰·Codex skill 절차 수정 시 |
| `agents/task-decomposer.md` | Task 세분화 기준·게이트 정의 | 계획/게이트 실행 시 |
| `agents/test-agent.md` | 런타임 검증 절차 정의 | worker 완료 후 |
| `.github/workflows/plans-guard.yml` | WIP 확인 + Acceptance Oracle + 세분화 CI | CI 수정 시 |
| `.github/workflows/plans-complete.yml` | 머지 시 cc:WIP→완료 자동 커밋 (stale WIP 방지) | CI 수정 시 |
| `docs/PRD.md`, `docs/UserFlow.md`, `docs/Architecture.md` | 기획 산출물 | 기획 참조 시 |
| `docs/templates/` | 기획 문서 골격 4종 (PRD·UserFlow·DESIGN·Architecture) | 새 기획 착수 시 |
