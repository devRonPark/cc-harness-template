# Harness Observability / Traceability / Context Preservability

이 문서는 실행 중 생긴 사실을 어디에 남길지 정하는 짧은 기준이다. 자동화를
늘리기 위한 문서가 아니라, 다음 세션과 리뷰어가 같은 증거를 빠르게 찾게 하는
운영 규칙이다.

## Observability

무슨 일이 있었는지는 아래 순서로 재구성한다.

1. `tasks/index.json` — 어떤 Task가 대상인지 확인한다.
2. `.harness/tasks/<task-key>/RUN_REPORT.md` — 실행 요약, 변경 파일, 검증 evidence를 본다.
3. `.harness/tasks/<task-key>/LOG.md` — 실패한 명령, 에러 원문, 긴 stdout/stderr를 본다.
4. `.harness/tasks/<task-key>/CHECKPOINTS.md` — 완료 지점과 커밋 해시를 확인한다.
5. `.harness/events/planning.jsonl` — planning 단계에서 proposal 흐름이나 실패를 확인한다.

`LOG.md`는 원문과 타임라인, `RUN_REPORT.md`는 사람이 빠르게 읽는 요약이다. 긴
출력은 `RUN_REPORT.md`에 붙이지 않는다.

## Traceability

왜 바뀌었는지는 아래 연결로 남긴다.

- 사용자 요청 또는 기획 문서 → `tasks/index.json` Task
- Task DoD/Acceptance → 실행 명령과 결과
- 주요 판단 → `RUN_REPORT.md`의 `Traceability` 섹션
- 반복될 수 있는 실수 → `.harness/LESSONS.md`
- 큰 제품/아키텍처 결정 → PRD `Decisions` 섹션 또는 필요 시 `docs/adr/`

작은 운영 결정 때문에 ADR을 만들 필요는 없다. 대신 Task별 `RUN_REPORT.md`에 결정과
근거를 한 줄로 남긴다.

## Context Preservability

세션이 끊기거나 context compaction이 일어나면 아래만 먼저 읽는다.

1. `tasks/index.json`
2. `.harness/tasks/<task-key>/STATE.md`
3. `.harness/tasks/<task-key>/RUN_REPORT.md`
4. `.harness/LESSONS.md` 최근 항목
5. `Plans.md`
6. `.harness/CONTEXT_INDEX.md`에서 필요한 추가 파일

위험한 context 자동화는 기본으로 켜지지 않는다. hooks를 쓰려면
`docs/claude-code-hooks.md`의 optional 예시처럼 프로젝트별로 명시적으로 추가한다.
