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
| `CLAUDE.md` | 프로젝트 규칙 (기획·구현·테스트·리뷰·상태 문서) | 규칙 확인 시 |
| `harness.toml` | harness 플러그인 설정 ([plan]·[test]·[review]) | 설정 변경 시 |
| `BLUEPRINT.md` | 시스템 전체 아키텍처 설명 (읽기용) | 구조 이해 필요 시 |
| `README.md` | 템플릿 사용법 (외부 사용자용) | 문서 갱신 시 |
| `agents/task-decomposer.md` | Task 세분화 기준·게이트 정의 | 계획/게이트 실행 시 |
| `agents/test-agent.md` | 런타임 검증 절차 정의 | worker 완료 후 |
| `.github/workflows/plans-guard.yml` | header-check·WIP 확인·diff 보호·depends 검증·Acceptance Oracle·세분화 CI (6잡) | CI 수정 시 |
| `.github/workflows/plans-complete.yml` | 머지 시 cc:WIP→완료 자동 커밋, push 실패 시 PR 폴백 (stale WIP 방지, H1) | CI 수정 시 |
| `.github/workflows/ci.yml` | 스택 빌드·테스트 + ci-ok 요약 잡(required check 이름 고정) | CI 수정 시 |
| `init.sh` | 새 프로젝트에 이 템플릿 전체(설정+CI+골격) 자동 복사 | 새 프로젝트 적용 시 |
| `templates/skeleton/` | init.sh가 복사하는 Plans.md·.harness/ 초기 상태 (dogfood 이력 없음) | 골격 자체를 고칠 때 |
| `docs/PRD.md`, `docs/UserFlow.md`, `docs/Architecture.md` | 기획 산출물 | 기획 참조 시 |
| `docs/templates/` | 기획 문서 골격 4종 (PRD·UserFlow·DESIGN·Architecture) | 새 기획 착수 시 |
| `docs/github-integration.md` | GitHub 연동 상세 가이드 (branch protection·CI 잡 6종·plans-complete 동작) | GitHub 연동 설정 시 |
| `docs/specs/2026-07-04-template-audit.md` | 템플릿 빈틈 감사 보고서 (H1~H5·M1~M8·L1~L5), Week 3 Task 매핑 근거 (L1~L5는 Plans.md Week 4 Task 4.1~4.6로 전환됨) | 감사 배경 확인 시 |
| `docs/claude-code-hooks.md` | hooks 미설정 현황 + 권장 hooks 예시, harness.toml [safety.permissions]와 역할 분담 | hooks 추가 검토 시 |
| `docs/session-recovery.md` | `.harness/` 재개 절차 심화 (파일별 역할·읽는 순서·실제 형식·다중 프로젝트 시나리오) | 세션 복구 절차 상세 확인 시 |
| `docs/error-memory.md` | `LOG.md`/`LESSONS.md` 작성 규칙·실제 형식·CLAUDE.md 승격 기준 | 에러 기록 규칙 확인 시 |
