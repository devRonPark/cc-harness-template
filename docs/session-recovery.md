# Session Recovery — 세션 복구 절차 심화

터미널 세션은 언제든 끊긴다는 전제로 이 템플릿을 만들었다. `.harness/`는
그 전제에 대응하는 상태 문서 세트다. 이제 루트 `.harness/*.md`는 템플릿이고,
실제 작업 맥락은 `.harness/tasks/<task-key>/` 아래에 Task별로 보관한다.

---

## 읽는 순서 (고정)

CLAUDE.md 상태 문서 규칙에 박혀 있는 순서다.

1. **`tasks/index.json`** — Task 상태 단일 출처. `wip` Task가 있으면 그게 재개 지점이다.
2. **`.harness/tasks/<task-key>/STATE.md`** — 해당 Task의 현재 스냅샷.
3. **`.harness/LESSONS.md`** — 전역 재발 방지 기록. 최근 항목만 우선 읽는다.
4. **`Plans.md`** — 사람이 읽는 snapshot. stale일 수 있으며 직접 편집하지 않는다.
5. 그 다음은 **필요할 때만**, `.harness/CONTEXT_INDEX.md`로 골라서 읽는다.

루트 `.harness/STATE.md`, `HANDOFF.md`, `TASKS.md`, `LOG.md`, `CHECKPOINTS.md`,
`RUN_REPORT.md`는
복사용 템플릿이다. 실제 진행 상태를 찾으려고 루트 템플릿을 읽지 않는다.

---

## Task별 파일 역할

| 파일 | 역할 | 갱신 시점 |
|------|------|-----------|
| `.harness/tasks/<task-key>/STATE.md` | 해당 Task 현재 스냅샷 | 작업 시작 전·단위 종료 후 |
| `.harness/tasks/<task-key>/HANDOFF.md` | 다음 세션이 최소한으로 읽을 것 + 재개 지점 + 주의사항 | 세션 종료 시(또는 끊김 대비) |
| `.harness/tasks/<task-key>/TASKS.md` | Task 내부 체크리스트 | Task 착수·완료 시 |
| `.harness/tasks/<task-key>/LOG.md` | 해당 Task 작업·에러 append-only 로그 | 매 작업/에러 발생 시 |
| `.harness/tasks/<task-key>/CHECKPOINTS.md` | 해당 Task 작업 단위 완료 + 커밋 해시 | 완료 지점마다 |
| `.harness/tasks/<task-key>/RUN_REPORT.md` | 실행 요약, 결정 근거, 검증 evidence | 완료/인수인계/감사 시 |
| `.harness/tasks/<task-key>/tasks.index.snapshot.json` | 작업 시작 시점의 `tasks/index.json` 참고본 | Task 시작 시 |

루트 `.harness/LESSONS.md`는 전역 재발 방지 기록으로 유지한다. 같은 유형의 실수가
다른 Task에서도 반복될 수 있기 때문이다. 루트 `.harness/CONTEXT_INDEX.md`는 파일
역할과 읽는 순서 인덱스다.

**Task 상태의 단일 출처는 `tasks/index.json`이다.** `Plans.md`는 사람이 필요할 때
여기서 생성하는 snapshot이다. Task별 `.harness/` 파일은 세션 맥락을 담을 뿐,
상태 판정의 단일 출처가 아니다.

---

## 새 Task 디렉토리 만들기

```bash
mkdir -p .harness/tasks/<task-key>
cp .harness/STATE.md .harness/tasks/<task-key>/STATE.md
cp .harness/HANDOFF.md .harness/tasks/<task-key>/HANDOFF.md
cp .harness/TASKS.md .harness/tasks/<task-key>/TASKS.md
cp .harness/LOG.md .harness/tasks/<task-key>/LOG.md
cp .harness/CHECKPOINTS.md .harness/tasks/<task-key>/CHECKPOINTS.md
cp .harness/RUN_REPORT.md .harness/tasks/<task-key>/RUN_REPORT.md
cp tasks/index.json .harness/tasks/<task-key>/tasks.index.snapshot.json
```

`<task-key>`는 사람이 알아볼 수 있게 `4.12-task-harness-context`처럼 Task ID와 짧은
slug를 함께 쓴다.

---

## 여러 프로젝트를 동시에 운영할 때

이 템플릿을 여러 프로젝트에 각각 적용하면 `.harness/`도 프로젝트마다 독립적으로
생긴다. 프로젝트 A의 `.harness/tasks/.../STATE.md`가 프로젝트 B의 재개에 영향을
주지 않는다. 여러 프로젝트를 오갈 땐 세션 시작 시 `pwd`, `git status`, 그리고
`tasks/index.json`의 `wip` Task부터 확인한다.

---

## 모니터/훅이 주는 상태 요약은 참고만

세션 시작 시 어떤 모니터나 훅이 "WIP 1건" 같은 요약을 보여줄 수 있다. 이 요약이
`tasks/index.json`·`git status`의 실제 상태와 어긋난 사례가 있었다. 요약은
참고만 하고, 판단은 항상 `tasks/index.json`과 `git status` 직접 확인으로 한다.

---

## 실행 보고서와 원문 로그 분리

`LOG.md`는 실패한 명령, 에러 원문, 세부 작업 타임라인을 append-only로 남기는 곳이다.
`RUN_REPORT.md`는 다음 세션이나 리뷰어가 빠르게 읽을 요약이다. Task 완료 또는 중단
시점에는 `RUN_REPORT.md`에 변경 요약, 주요 결정 근거, Acceptance/test evidence,
남은 위험을 짧게 정리한다. 긴 stdout/stderr는 `RUN_REPORT.md`에 붙이지 말고
`LOG.md` 위치만 링크한다.

---

## 재개 프롬프트

```text
Read tasks/index.json to identify the wip or requested Task.
Then read .harness/tasks/<task-key>/STATE.md,
.harness/tasks/<task-key>/RUN_REPORT.md if it exists,
recent .harness/LESSONS.md entries, and Plans.md.
Resume from the last recorded state.
Do not repeat completed Tasks unless Acceptance requires re-verification.
Before continuing, summarize the current state and next action.
```

```text
tasks/index.json에서 wip 또는 지정된 Task를 확인한 뒤,
.harness/tasks/<task-key>/STATE.md, 있으면
.harness/tasks/<task-key>/RUN_REPORT.md, .harness/LESSONS.md 최근 항목,
Plans.md를 읽어줘.
마지막으로 기록된 상태부터 작업을 재개해줘.
Acceptance 재검증이 필요한 경우가 아니면 이미 완료된 Task는 반복하지 마.
계속하기 전에 현재 상태와 다음 작업을 먼저 요약해줘.
```

---

## 참고

- [../README.md](../README.md#session-recovery) — 요약
- [error-memory.md](./error-memory.md) — Task별 `LOG.md`와 전역 `LESSONS.md` 작성 규칙
- [../CLAUDE.md](../CLAUDE.md) — 상태 문서 규칙 원본
