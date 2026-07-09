---
name: harness-work
description: todo Task 하나를 선택해 세분화 게이트를 확인하고 구현, Acceptance, 테스트, 리뷰까지 진행한다. Task 구현 요청 시 사용.
---

# harness-work

Codex에서 Claude Code `/harness-work`에 해당하는 절차를 직접 수행한다.

## 절차

1. 최소 컨텍스트만 로드한다. 이미 세션에 로드된 규칙 문서(`CLAUDE.md`, `AGENTS.md`, `agents/quality-gates.md`)는 다시 읽지 않는다. Claude Code에서는 `CLAUDE.md`가 자동 로드되고 `AGENTS.md`는 Codex 세션 전용이다. `agents/quality-gates.md`는 루프당 1회만 읽는다. `Plans.md`는 생성물이므로 읽지 않는다(쓰기 전용). `.harness/LESSONS.md`는 전체가 아니라 최근 5개 항목만 부분 읽기한다. 진행 중인 Task가 있으면 `.harness/tasks/<task-key>/STATE.md`도 읽는다.
2. 수행할 `todo` Task 하나를 고른다. `tasks/index.json`을 전체 Read 하지 않는다 — `python3 scripts/report_tasks.py`로 WIP/next TODO 요약을 보고 고른 뒤, 선택한 Task의 상세(dod/acceptance/depends)는 `grep -n -A12 '"id": "<task-id>"' tasks/index.json`으로 해당 블록만 읽는다. 사용자가 지정한 Task가 있으면 그 Task를 우선한다.
3. 구현 전 1차 게이트로 DoD/Acceptance 존재, 단일 관심사, 1 PR 이내 규모를 확인하고, `agents/quality-gates.md`의 scope/YAGNI 체크를 적용한다. 미달이 의심될 때만 `agents/task-decomposer.md` 전체를 읽어 세분화 기준으로 판정한다.
4. 기준 미달이면 구현하지 말고 `$harness-plan` 절차로 하위 Task proposal을 만든다.
5. 기준 통과 시 구현 전에 반드시 대상 Task 전용 브랜치로 이동한다. `git branch --show-current`로 현재 브랜치를 확인하고, main/master이거나 다른 Task의 브랜치이면 `$branch-checkout` 절차로 `task/{task-id}-{short-slug}` 브랜치를 새로 만들거나 기존 Task 브랜치로 전환한다. main/master에서 직접 구현하지 않는다. 이미 main에 커밋하지 않은 작업이 쌓여 있으면 `$rescue-from-main` 절차로 옮긴다. 그 다음 `.harness/tasks/<task-key>/STATE.md`를 갱신하고 구현한다. Task 디렉토리가 없으면 루트 템플릿 중 `STATE.md`, `LOG.md`, `RUN_REPORT.md` 3종만 복사해 만든다. `HANDOFF.md`, `TASKS.md`, `CHECKPOINTS.md`는 실제로 필요해질 때만 추가한다.
6. 작업 중 범위가 커지면 중단하고 `agents/quality-gates.md`의 split 조건과 task-decomposer 기준으로 재분해한다.
7. 기능, 버그 수정, 동작 변경은 구현 전 failing test 또는 failing Acceptance를 먼저 확인한다. 문서, 설정, 생성 코드, throwaway prototype은 TDD 예외 사유를 기록한다.
8. 구현 후 `agents/test-agent.md` 절차대로 해당 Task Acceptance 명령과 관련 테스트 스위트를 fresh verification으로 실행한다.
9. 검증 실패 시 수정 후 재실행한다.
10. 검증 통과 후 `$harness-review` 절차로 현재 diff를 리뷰한다.

## 완료 기준

- 구현 커밋이 대상 Task 전용 브랜치에 있어야 한다. main/master 직접 커밋은 완료로 인정하지 않는다.
- Acceptance와 관련 테스트가 fresh verification으로 통과해야 한다.
- TDD evidence 또는 명시적 예외 사유가 있어야 한다.
- `.harness/tasks/<task-key>/RUN_REPORT.md`에 변경 요약, 주요 결정 근거,
  TDD evidence, Acceptance/test evidence, 남은 위험을 짧게 남긴다.
- Acceptance와 관련 테스트 통과 후 에이전트가 `tasks/index.json`의 대상 Task를
  `done`으로 갱신하고 `Plans.md`를 재생성한다. GitHub Actions는 Task 상태를
  전환하지 않는다.
- 새 파일이나 역할 변경은 `.harness/CONTEXT_INDEX.md`에 반영한다.
- 루트 `.harness/STATE.md`, `HANDOFF.md`, `TASKS.md`, `LOG.md`, `CHECKPOINTS.md`,
  `RUN_REPORT.md`는 템플릿이므로 실제 진행 상태를 쓰지 않는다.
- ponytail/caveman Codex plugin 자동 동작을 가정하지 않는다. Codex에서는
  `agents/quality-gates.md`를 직접 적용한다.
