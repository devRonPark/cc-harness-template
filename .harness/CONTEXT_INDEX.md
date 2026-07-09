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

`.harness/tasks/<task-key>/` 아래에 실제 작업 맥락을 둔다.

- `STATE.md`: 현재 스냅샷
- `LOG.md`: 작업·에러 원문
- `RUN_REPORT.md`: 변경·결정·검증 요약
- `HANDOFF.md`, `TASKS.md`, `CHECKPOINTS.md`: 필요할 때만 읽는 보조 기록
- `tasks.index.snapshot.json`: 시작 시점 비교가 필요할 때만 읽는 참고본

## 루트 `.harness/` 템플릿과 전역 파일

- `.harness/{STATE,HANDOFF,TASKS,LOG,CHECKPOINTS,RUN_REPORT}.md`: 새 Task용 템플릿
- `.harness/LESSONS.md`: 전역 재발 방지 기록
- `.harness/CONTEXT_INDEX.md`: 필요한 파일만 고르는 인덱스
- `.harness/events/planning.jsonl`: planning 실패·반영 흐름 추적
- `.harness/shared/planning/latest.json`: 최신 planning run 위치
- `.harness/shared/planning/runs/`: 특정 planning run 감사 시만 읽는 작업대

## 필요할 때만

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `CLAUDE.md` | 프로젝트 규칙 (기획·구현·테스트·리뷰·상태 문서) | 규칙 확인 시 |
| `AGENTS.md` | Codex 진입점. CLAUDE.md 규칙을 Codex 세션에서 동일 절차로 실행하기 위한 호환 지침 | Codex 환경 구성·규칙 확인 시 |
| `.agents/skills/` | Codex repo-scoped skills (`$grill-me`, `$harness-plan`, `$harness-work`, `$harness-review`, `$harness-progress`, `$harness-sync`, `$harness-yagni-trimmer`, `$branch-checkout`, `$git-push`, `$pr-create`, `$rescue-from-main`) | Codex skill 호출 UX·절차 수정 시 |
| `.claude/commands/` | Claude Code local custom commands (`/branch-checkout`, `/git-push`, `/pr-create`, `/rescue-from-main`) | Claude command 호출 UX·절차 수정 시 |
| `harness.toml` | harness 플러그인 설정 요약 인덱스 ([plan]·[test]·[review]) | 설정 변경 시 |
| `BLUEPRINT.md` | 시스템 전체 아키텍처 설명 (읽기용) | 구조 이해 필요 시 |
| `README.md` | 템플릿 사용법 (외부 사용자용) | 문서 갱신 시 |
| `agents/quality-gates.md` | Claude/Codex 공통 scope·YAGNI·review·reporting 게이트 | 구현·리뷰·Codex skill 절차 수정 시 |
| `agents/task-decomposer.md` | Task 세분화 기준·게이트 정의 | 계획/게이트 실행 시 |
| `agents/test-agent.md` | 런타임 검증 절차 정의 | worker 완료 후 |
| `.github/workflows/plans-guard.yml` | header-check·WIP 확인·diff 보호·depends 검증·Acceptance Oracle·세분화 CI | CI 수정 시 |
| `.github/workflows/ci.yml` | 스택 빌드·테스트 + ci-ok 요약 잡 | CI 수정 시 |
| `init.sh` | 새 프로젝트에 이 템플릿 전체(설정+CI+골격) 자동 복사 | 새 프로젝트 적용 시 |
| `templates/skeleton/` | init.sh가 복사하는 Plans.md·.harness/ 초기 템플릿 구조 | 골격 자체를 고칠 때 |
| `docs/templates/` | 기획 문서 골격 4종 (PRD·UserFlow·DESIGN·Architecture) | 새 기획 착수 시 |
| `docs/github-integration.md` | GitHub 연동 상세 가이드 | GitHub 연동 설정 시 |
| `docs/specs/2026-07-04-template-audit.md` | 템플릿 빈틈 감사 보고서 | 감사 배경 확인 시 |
| `docs/specs/2026-07-08-codex-claude-quality-gates.md` | Claude/Codex quality gate 경계 기록 | 품질 게이트 설계 배경 확인 시 |
| `docs/claude-code-hooks.md` | hooks 미설정 현황 + 권장 hooks 예시 | hooks 추가 검토 시 |
| `docs/harness-observability-traceability.md` | 실행 요약, 원문 로그, 결정 근거, context 보존 위치 | harness 운영 증거 위치 확인 시 |
| `docs/session-recovery.md` | `.harness/tasks/` 기반 재개 절차 심화 | 세션 복구 절차 상세 확인 시 |
| `docs/error-memory.md` | Task별 `LOG.md`와 전역 `LESSONS.md` 작성 규칙 | 에러 기록 규칙 확인 시 |
