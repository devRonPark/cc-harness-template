---
name: harness-work
description: todo Task 하나를 선택해 세분화 게이트를 확인하고 구현, Acceptance, 테스트, 리뷰까지 진행한다. Task 구현 요청 시 사용.
---

# harness-work

Codex에서 Claude Code `/harness-work`에 해당하는 절차를 직접 수행한다.

## 절차

1. `AGENTS.md`, `CLAUDE.md`, `agents/quality-gates.md`, `.harness/STATE.md`, 최근 `.harness/LESSONS.md`, `tasks/index.json`, `Plans.md`를 읽는다.
2. 수행할 `todo` Task 하나를 고른다. 사용자가 지정한 Task가 있으면 그 Task를 우선한다.
3. 구현 전 `agents/task-decomposer.md`의 세분화 기준과 `agents/quality-gates.md`의 scope/YAGNI 체크를 확인한다.
4. 기준 미달이면 구현하지 말고 `$harness-plan` 절차로 하위 Task proposal을 만든다.
5. 기준 통과 시 `.harness/STATE.md`를 갱신하고 구현한다.
6. 작업 중 범위가 커지면 중단하고 `agents/quality-gates.md`의 split 조건과 task-decomposer 기준으로 재분해한다.
7. 구현 후 `agents/test-agent.md` 절차대로 해당 Task Acceptance 명령과 관련 테스트 스위트를 실행한다.
8. 검증 실패 시 수정 후 재실행한다.
9. 검증 통과 후 `$harness-review` 절차로 현재 diff를 리뷰한다.

## 완료 기준

- Acceptance와 관련 테스트가 통과해야 한다.
- GitHub 모드에서는 PR 안에서 Task를 `done`으로 바꾸지 않는다. merge 후 `plans-complete.yml`이 전환한다.
- 새 파일이나 역할 변경은 `.harness/CONTEXT_INDEX.md`에 반영한다.
- ponytail/caveman Codex plugin 자동 동작을 가정하지 않는다. Codex에서는
  `agents/quality-gates.md`를 직접 적용한다.
