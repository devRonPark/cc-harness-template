# CONTEXT_INDEX.md — 파일 역할 인덱스

> 루트 `.harness/*.md`는 템플릿이고, 실제 작업 맥락은 `.harness/tasks/<task-key>/`에 있다.

## 세션 재개 읽는 순서

1. `python3 scripts/report_tasks.py`로 `wip` Task 또는 사용자가 지정한 Task를 확인한다.
   Task 상세는 `grep -n -A12 '"id": "<task-id>"' tasks/index.json`으로 해당 블록만 읽는다.
2. 해당 Task의 `.harness/tasks/<task-key>/STATE.md`를 읽는다.
3. 루트 `.harness/LESSONS.md` 최근 5개 항목만 읽는다.
4. 이 파일에서 필요한 추가 문서만 고른다. `Plans.md`는 사람용 snapshot이므로
   에이전트는 읽지 않는다.

## Task별 맥락 디렉토리

`.harness/tasks/<task-key>/` 아래에 실제 작업 맥락을 둔다.

- `STATE.md`: 현재 스냅샷
- `LOG.md`: 작업·에러 원문
- `RUN_REPORT.md`: 변경·결정·검증 요약
- `HANDOFF.md`, `TASKS.md`, `CHECKPOINTS.md`: 기본 복사 대상이 아니며, 필요할 때만 생성·읽는 보조 기록
- `tasks.index.snapshot.json`: 시작 시점 비교가 필요할 때만 읽는 참고본

## 루트 템플릿과 전역 파일

- `.harness/{STATE,HANDOFF,TASKS,LOG,CHECKPOINTS,RUN_REPORT}.md`: 새 Task용 템플릿
- `.harness/LESSONS.md`: 전역 재발 방지 기록
- `.harness/CONTEXT_INDEX.md`: 필요한 파일만 고르는 인덱스
- `.harness/events/planning.jsonl`: planning 실패·반영 흐름 추적
- `.harness/shared/planning/latest.json`: 최신 planning run 위치
