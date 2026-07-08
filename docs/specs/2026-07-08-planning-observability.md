# Planning Observability — 비개발자도 이해 가능한 Task 분해 감시 구조

## Summary

- `/harness-plan`의 기본 흐름은 독립 task-decomposer proposal 방식으로 정의한다.
- v1의 독립 실행은 "외부 명령 계약"으로 제한한다. 설정된 decomposer 명령이
  없거나 실패하면 쉬운 실패 로그를 남기고, 허용된 경우에만 inline fallback을
  사용한다.
- 확정 Task의 SSOT는 계속 `tasks/index.json`이다. decomposer는 확정 파일을
  직접 수정하지 않는다.
- planning 단계만 v1 감시 대상으로 삼는다. `/harness-work`, `/harness-review`,
  SQLite, 범용 이벤트 프레임워크는 제외한다.
- 로그와 보고서는 개발자가 아닌 사용자도 이해할 수 있는 문장을 최상위에 두고,
  도구용 값은 `technical` 하위에 둔다.

## Key Changes

- 공유 planning 작업대는 run 단위로 분리한다.
  - `.harness/shared/planning/runs/{run_id}/context.json`
  - `.harness/shared/planning/runs/{run_id}/proposed-tasks.json`
  - `.harness/shared/planning/runs/{run_id}/decomposition-report.md`
  - `.harness/shared/planning/latest.json`: 최신 run의 경로만 가리키는 작은 인덱스
  - `.harness/events/planning.jsonl`: planning 단계 JSONL 로그
- `planning.jsonl`의 사용자 친화 필드:
  - `time`: 발생 시각
  - `step`: `요청 정리`, `작업 나누기 시작`, `성공 기준 검사`, `작업 목록 반영`,
    `계획 문서 갱신`, `실패`
  - `result`: `시작`, `성공`, `실패`, `반영됨`
  - `message`: 사용자가 이해할 수 있는 설명
  - `next_action`: 실패하거나 멈췄을 때 할 일
  - `details_file`: 자세한 설명 파일 경로
  - `technical`: `event`, `run_id`, `files`, `command_exit_code` 등 도구용 값
- `harness.toml`의 `[plan]` 요약 인덱스에 추가한다. 실행 SSOT는 계속
  `CLAUDE.md`다.
  - `decomposer_mode = "process"`
  - `decomposer_command = ""`
  - `allow_inline_fallback = true`
  - `proposal_dir = ".harness/shared/planning"`
  - `planning_event_log = ".harness/events/planning.jsonl"`
- 독립 decomposer 명령 계약:
  - 명령은 `context.json`을 입력으로 받고 `proposed-tasks.json`과
    `decomposition-report.md`를 생성해야 한다.
  - 명령이 비어 있거나 실패하면 `planning.jsonl`에 사람이 이해 가능한 실패
    이벤트를 남긴다.
  - fallback이 허용되면 현재 세션이 같은 파일 계약을 채운다.
  - fallback 사용도 반드시 로그에 남긴다.
- `proposed-tasks.json` 규칙:
  - 기존 호환을 위해 Task 필드는 `id`, `title`, `dod`, `acceptance`, `depends`,
    `status`, `gh`, `section`을 유지한다.
  - 새 proposal의 `status`는 항상 `todo`, `gh`는 `-`로 시작한다.
  - `dod`와 `title` 값은 비개발자도 이해 가능한 문장으로 쓴다.
  - apply 직전에 현재 `tasks/index.json`을 다시 읽어 ID 충돌과 Depends를
    재검증한다.
- `decomposition-report.md` 규칙:
  - "이번에 만든 작업", "자동 반영하지 않은 항목", "사용자 확인이 필요한 결정"
    섹션을 둔다.
  - `DoD`, `Acceptance`, `Depends`만 쓰지 않고 `완료 기준`, `확인 방법`,
    `먼저 끝나야 할 작업`으로 풀어 쓴다.
  - `Acceptance: -`는 왜 자동 확인이 어려운지 설명한다.

## Implementation Changes

- 골격 추가:
  - 현재 repo와 `templates/skeleton/.harness/`에
    `shared/planning/runs/.gitkeep`와 `events/.gitkeep`를 추가한다.
  - `init.sh`의 기존 `.harness` 복사 흐름으로 새 골격이 포함되게 한다.
- 스크립트 추가:
  - `scripts/planning_log.py`: planning 전용 JSONL append. 범용 이벤트
    프레임워크로 만들지 않는다.
  - `scripts/build_planning_context.py`: 사용자 요청, 기획 문서 경로, 기존 Task
    요약, task-decomposer 규칙 경로를 run 디렉토리의 `context.json`에 저장한다.
  - `scripts/run_task_decomposer.py`: 외부 decomposer 명령 계약을 실행하고,
    명령 미설정·실패·산출물 누락을 사용자 친화 JSONL로 기록한다.
  - `scripts/validate_task_proposal.py`: proposal과 현재 task 목록을 함께
    검증한다.
  - `scripts/apply_task_proposal.py`: apply 직전 재검증 후 `tasks/index.json`에
    append하고 `scripts/sync_plans.py`를 실행한다.
- 문서 갱신:
  - `agents/task-decomposer.md`: 독립 proposal 기본, 직접 apply 금지, 쉬운 문장
    작성 규칙 명시.
  - `CLAUDE.md`, `README.md`, `BLUEPRINT.md`, `docs/session-recovery.md`,
    `CONTEXT_INDEX.md`: planning run 디렉토리, JSONL 감시, fallback, 실패 처리
    흐름 문서화.
- 실패 처리:
  - JSON 파싱 실패, 필수 파일 누락, validation 실패, apply 전 충돌은 모두
    `planning.jsonl`에 쉬운 메시지로 기록한다.
  - 원문 에러가 있으면 기존 규칙대로 `.harness/LOG.md`에도 기록한다.

## Explicitly Out Of V1

- `work.jsonl`
- `review.jsonl`
- `/harness-work` 이벤트
- `/harness-review` 이벤트
- 범용 `harness_events.py` 추상화
- SQLite 또는 `.sql`
- 복잡한 decomposer runner 추상화
- 모든 대화 턴 결과 기록

## Test Plan

- 단위 테스트:
  - `planning_log.py`가 사용자 친화 필드와 `technical` 필드를 포함한 JSONL 한
    줄을 append한다.
  - `build_planning_context.py`가 run별 디렉토리를 만들고 `latest.json`을 갱신한다.
  - proposal 검증이 정상 proposal을 통과시킨다.
  - `true`, `|| echo skip`, repo 밖 경로 acceptance가 proposal에서도 실패한다.
  - 기존 Task ID와 중복되는 proposal이 실패한다.
  - apply 직전 `tasks/index.json`이 바뀐 경우 재검증에서 실패한다.
- 통합 시나리오:
  - decomposer 명령이 비어 있으면 `실패` 이벤트와 `next_action`이 기록된다.
  - fallback 허용 시 inline proposal을 만들어 검증과 apply를 완료한다.
  - 적용 후 `python3 scripts/sync_plans.py --check`가 통과한다.
  - `python3 scripts/validate_tasks.py`가 통과한다.
  - `tail -f .harness/events/planning.jsonl`로 봤을 때 비개발자도 단계와 다음
    행동을 이해할 수 있다.
- 회귀 테스트:
  - 기존 `python3 -m unittest tests.test_tasks -v` 통과.
  - `init.sh`로 새 임시 프로젝트에 복사했을 때 `.harness/shared/planning/runs/`와
    `.harness/events/`가 포함된다.

## Assumptions

- v1의 "독립 decomposer 기본"은 외부 명령 계약을 기본 실행 방식으로 둔다는
  뜻이다. 템플릿 자체가 특정 LLM/agent provider를 강제하지 않는다.
- `decomposer_command`가 비어 있으면 독립 실행은 명확히 실패로 기록되고,
  `allow_inline_fallback = true`일 때만 현재 세션 fallback으로 이어진다.
- 기존 `tasks/index.json` 필드명은 호환성 때문에 유지한다. 대신 값과 보고서는
  쉬운 표현을 우선한다.
- `.harness/LOG.md`는 에러 원문과 중요 작업 이력을 남기는 사람이 읽는 로그이며,
  planning 자동 감시는 `.harness/events/planning.jsonl`만 사용한다.
