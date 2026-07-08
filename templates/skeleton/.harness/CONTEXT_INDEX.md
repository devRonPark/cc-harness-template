# CONTEXT_INDEX.md — 파일 역할 인덱스

> 루트 `.harness/*.md`는 템플릿이고, 실제 작업 맥락은 `.harness/tasks/<task-key>/`에 있다.

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

## 루트 템플릿과 전역 파일

| 파일 | 역할 | 읽는 시점 |
|------|------|-----------|
| `.harness/STATE.md` | Task별 `STATE.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/HANDOFF.md` | Task별 `HANDOFF.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/TASKS.md` | Task별 `TASKS.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/LOG.md` | Task별 `LOG.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/CHECKPOINTS.md` | Task별 `CHECKPOINTS.md` 복사용 템플릿 | 새 Task 디렉토리 만들 때 |
| `.harness/LESSONS.md` | 전역 재발 방지 기록 | 매 세션 시작 |
| `.harness/CONTEXT_INDEX.md` | 파일 역할·읽는 순서 인덱스 | 세션 재개/파일 역할 확인 시 |
| `.harness/events/planning.jsonl` | `/harness-plan` 단계별 감시 로그 | planning 실패·반영 흐름 추적 시 |
| `.harness/shared/planning/latest.json` | 최신 planning run 위치 | 최신 proposal 확인 시 |
