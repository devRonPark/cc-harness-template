---
name: harness-progress
description: tasks/index.json 기준으로 진행 상황을 읽기 전용 요약한다. 상태 확인, 진행률, 다음 작업 추천 요청 시 사용.
---

# harness-progress

`tasks/index.json`을 단일 출처로 진행 상황을 요약한다. 기본적으로 상태를 변경하지 않는다.

## 절차

1. 이미 세션에 로드된 규칙 문서(`AGENTS.md`, `CLAUDE.md`)는 재독하지 않는다. `tasks/index.json`을 전체 Read 하지 않는다.
2. `python3 scripts/report_tasks.py`를 실행해 요약을 얻는다. 특정 Task 상세가 필요하면 `grep -n -A12 '"id": "<task-id>"' tasks/index.json`으로 해당 블록만 읽는다.
3. `todo`, `wip`, `blocked`, `done` 수와 다음에 착수 가능한 Task를 요약한다.
4. `Plans.md`가 stale일 가능성이 있으면 `python3 scripts/sync_plans.py --check` 결과를 보고한다.

## 규칙

- 사용자가 명시적으로 요청하지 않으면 `Plans.md`를 재생성하지 않는다.
- Task 상태를 바꾸지 않는다.
