---
name: harness-review
description: 현재 diff를 Task, CLAUDE.md 규칙, Acceptance evidence 기준으로 코드 리뷰한다. 리뷰 요청이나 PR 전 점검 시 사용.
---

# harness-review

Codex에서 Claude Code `/harness-review`에 해당하는 리뷰 절차를 수행한다.

## 절차

1. `AGENTS.md`, `CLAUDE.md`, `agents/quality-gates.md`, 대상 Task, Acceptance evidence, 현재 diff를 읽는다.
2. 코드 리뷰 관점으로 버그, 회귀 위험, 누락된 테스트, 규칙 위반, `agents/quality-gates.md` 위반을 우선 찾는다.
3. findings를 심각도순으로 먼저 보고하고, 각 항목은 파일·라인 근거를 포함한다.
4. 문제가 없으면 "발견 없음"을 명확히 말하고 남은 테스트 gap이나 잔여 위험만 짧게 남긴다.

## 판정

- `APPROVE`: blocker 없음, Acceptance evidence가 충분함.
- `REQUEST_CHANGES`: 동작 버그, 규칙 위반, Acceptance 미실행/실패, 테스트 누락이 Task 완료를 막음.

리뷰 중 직접 수정하지 않는다. 수정이 필요하면 findings를 근거로 구현 단계로 되돌린다.
findings는 `agents/quality-gates.md`의 review/reporting gate처럼 먼저 보고하고,
문제가 없으면 테스트 gap과 잔여 위험만 짧게 남긴다.
