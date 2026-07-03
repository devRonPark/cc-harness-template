# HANDOFF.md — 다음 세션 인수인계

> 세션 종료(또는 끊김 대비) 시점에 갱신. 다음 세션이 전체 파일을 다시 읽지 않고
> 여기 적힌 최소 파일만 읽고 바로 이어가게 하는 것이 목적.

## 다음 세션이 먼저 읽을 최소 파일

1. `.harness/STATE.md` — 현재 상태
2. `.harness/LESSONS.md` — 최근 5개 항목
3. `Plans.md` — Task 상태 (cc:WIP 행 확인)

## 재개 지점

- Task 1.4 완료 (Acceptance PASS), **미커밋** — .harness/ 7파일 + CLAUDE.md +
  Plans.md 변경분이 working tree에 있음. 사용자 커밋 요청 시 바로 커밋 가능.
- 커밋 후 다음 작업은 Week 2 Task 정의 (사용자 입력 필요).

## 주의사항

- 커밋은 사용자 명시 요청 전까지 금지.
- Task 상태는 Plans.md가 단일 출처 — .harness/TASKS.md에 Task 상태를 복제하지 말 것.
- Week 2 Task 2.1은 placeholder — 내용은 사용자에게 물어야 함.
- CLAUDE.md 118줄 — 훅이 분할 권고(.claude/rules/ 또는 docs/ 참조). 스코프 확장이라
  미실행, 사용자 판단 대기.
