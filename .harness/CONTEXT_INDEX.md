# CONTEXT_INDEX.md — 파일 역할 인덱스

> 토큰 절약용. 세션 재개 시 이 인덱스로 "이번 작업에 필요한 파일"만 골라 읽는다.
> 루트 `.harness/*.md`는 템플릿이고, 실제 작업 맥락은 `.harness/tasks/<task-key>/`에 있다.
> 새 파일을 만들거나 기존 파일의 역할이 바뀌면 여기를 갱신한다.

## 세션 재개 읽는 순서

1. `tasks/index.json`에서 `wip` Task 또는 사용자가 지정한 Task를 확인한다.
2. 해당 Task의 `.harness/tasks/<task-key>/STATE.md`를 읽는다.
3. 루트 `.harness/LESSONS.md` 최근 항목을 읽는다.
4. `Plans.md`를 읽어 사람이 보는 snapshot을 확인한다.
5. 이 파일에서 필요한 추가 문서만 고른다.

## Task별 맥락 디렉토리

| 경로 | 역할 | 읽는 시점 |
|------|------|-----------|
| `.harness/tasks/<task-key>/STATE.md` | 해당 Task의 현재 스냅샷 | Task 재개 시 |
| `.harness/tasks/<task-key>/LOG.md` | 해당 Task 작업·에러 로그 | 작업 이력/에러 확인 시 |
| `.harness/tasks/<task-key>/CHECKPOINTS.md` | 해당 Task 완료 지점 기록 | 완료 근거 확인 시 |
| `.harness/tasks/<task-key>/HANDOFF.md` | 해당 Task 재개 정보 | 세션 재개 직후 |
| `.harness/tasks/<task-key>/TASKS.md` | 해당 Task 내부 체크리스트 | Task 진행 중 |
| `.harness/tasks/<task-key>/tasks.index.snapshot.json` | 작업 시작 시점의 `tasks/index.json` 참고본 | 시작 시점 비교가 필요할 때 |

## 루트 `.harness/` 템플릿과 전역 파일

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `.harness/STATE.md` | Task별 `STATE.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/HANDOFF.md` | Task별 `HANDOFF.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/TASKS.md` | Task별 `TASKS.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/LOG.md` | Task별 `LOG.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/CHECKPOINTS.md` | Task별 `CHECKPOINTS.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/LESSONS.md` | 전역 재발 방지 기록 (최근 항목 우선) | 매 세션 시작 |
| `.harness/CONTEXT_INDEX.md` | 파일 역할·읽는 순서 인덱스 | 세션 재개/파일 역할 확인 시 |
| `.harness/events/planning.jsonl` | `/harness-plan` 단계별 감시 로그 | planning 실패·반영 흐름 추적 시 |
| `.harness/shared/planning/latest.json` | 최신 planning run의 context/proposal/report 위치 | 최신 task-decomposer proposal 확인 시 |
| `.harness/shared/planning/runs/` | run별 context.json·proposed-tasks.json·decomposition-report.md 작업대 | 특정 planning run 감사 시 |

## 필요할 때만

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `CLAUDE.md` | 프로젝트 규칙 (기획·구현·테스트·리뷰·상태 문서) | 규칙 확인 시 |
| `AGENTS.md` | Codex 진입점. CLAUDE.md 규칙을 Codex 세션에서 동일 절차로 실행하기 위한 호환 지침 | Codex 환경 구성·규칙 확인 시 |
| `.agents/skills/` | Codex repo-scoped skills (`$grill-me`, `$harness-plan`, `$harness-work`, `$harness-review`, `$harness-progress`, `$harness-sync`, `$branch-checkout`, `$git-push`, `$pr-create`, `$rescue-from-main`) | Codex skill 호출 UX·절차 수정 시 |
| `.claude/commands/` | Claude Code local custom commands (`/branch-checkout`, `/git-push`, `/pr-create`, `/rescue-from-main`) | Claude command 호출 UX·절차 수정 시 |
| `harness.toml` | harness 플러그인 설정 요약 인덱스 ([plan]·[test]·[review]) | 설정 변경 시 |
| `BLUEPRINT.md` | 시스템 전체 아키텍처 설명 (읽기용) | 구조 이해 필요 시 |
| `README.md` | 템플릿 사용법 (외부 사용자용) | 문서 갱신 시 |
| `agents/quality-gates.md` | Claude/Codex 공통 scope·YAGNI·review·reporting 게이트 | 구현·리뷰·Codex skill 절차 수정 시 |
| `agents/task-decomposer.md` | Task 세분화 기준·게이트 정의 | 계획/게이트 실행 시 |
| `agents/test-agent.md` | 런타임 검증 절차 정의 | worker 완료 후 |
| `.github/workflows/plans-guard.yml` | header-check·WIP 확인·diff 보호·depends 검증·Acceptance Oracle·세분화 CI | CI 수정 시 |
| `.github/workflows/plans-complete.yml` | 머지 시 cc:WIP→완료 자동 커밋, push 실패 시 PR 폴백 | CI 수정 시 |
| `.github/workflows/ci.yml` | 스택 빌드·테스트 + ci-ok 요약 잡 | CI 수정 시 |
| `init.sh` | 새 프로젝트에 이 템플릿 전체(설정+CI+골격) 자동 복사 | 새 프로젝트 적용 시 |
| `templates/skeleton/` | init.sh가 복사하는 Plans.md·.harness/ 초기 템플릿 구조 | 골격 자체를 고칠 때 |
| `docs/templates/` | 기획 문서 골격 4종 (PRD·UserFlow·DESIGN·Architecture) | 새 기획 착수 시 |
| `docs/github-integration.md` | GitHub 연동 상세 가이드 | GitHub 연동 설정 시 |
| `docs/specs/2026-07-04-template-audit.md` | 템플릿 빈틈 감사 보고서 | 감사 배경 확인 시 |
| `docs/specs/2026-07-08-codex-claude-quality-gates.md` | Claude/Codex quality gate 경계 기록 | 품질 게이트 설계 배경 확인 시 |
| `docs/claude-code-hooks.md` | hooks 미설정 현황 + 권장 hooks 예시 | hooks 추가 검토 시 |
| `docs/session-recovery.md` | `.harness/tasks/` 기반 재개 절차 심화 | 세션 복구 절차 상세 확인 시 |
| `docs/error-memory.md` | Task별 `LOG.md`와 전역 `LESSONS.md` 작성 규칙 | 에러 기록 규칙 확인 시 |
