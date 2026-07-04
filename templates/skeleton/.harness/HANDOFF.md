# HANDOFF.md — 다음 세션 인수인계

> 세션 종료(또는 끊김 대비) 시점에 갱신. 다음 세션이 전체 파일을 다시 읽지 않고
> 여기 적힌 최소 파일만 읽고 바로 이어가게 하는 것이 목적.

## 다음 세션이 먼저 읽을 최소 파일

1. `.harness/STATE.md` — 현재 상태
2. `.harness/LESSONS.md` — 최근 5개 항목
3. `Plans.md` — Task 상태 (cc:WIP 행 확인)

## 재개 지점

- 아직 세션 없음 (초기 상태). 첫 세션에서 `/grill-me`부터 시작.

## 주의사항

- Task 상태는 Plans.md가 단일 출처 — `.harness/TASKS.md`에 Task 상태를 복제하지 말 것.
