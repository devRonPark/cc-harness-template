# Error Memory — 반복 실패 방지 규칙

에러를 숨기지 않고 기록해서, 같은 실수를 같은 원인으로 두 번 반복하지 않게
하는 것이 Task별 `LOG.md`와 전역 `.harness/LESSONS.md`의 목적이다.

---

## `LOG.md`와 `LESSONS.md`의 차이

| | Task별 `LOG.md` | 루트 `LESSONS.md` |
|---|---|---|
| 경로 | `.harness/tasks/<task-key>/LOG.md` | `.harness/LESSONS.md` |
| 성격 | 해당 Task 작업·에러 일지 | 해결 후 전역 재발 방지 요약 |
| 순서 | 위→아래로 추가만 (시간순) | 최신 항목 우선 |
| 내용 | 실패한 명령·에러 메시지 원문, 해당 Task 작업 기록 | 원인 + 다음엔 어떻게 판단할지 |
| 읽는 시점 | 해당 Task 재개 또는 에러 이력 확인 시 | 세션 시작 시 최근 항목 우선 |
| 승격 | — | 항상 지킬 규칙이면 `CLAUDE.md`에도 반영 |

루트 `.harness/LOG.md`는 복사용 템플릿이다. 실제 에러 원문은 반드시 해당 Task의
`.harness/tasks/<task-key>/LOG.md`에 남긴다.
Task가 끝나거나 중단될 때 `.harness/tasks/<task-key>/RUN_REPORT.md`에는 에러 원문을
반복하지 않고 원인, 해결 요약, 검증 evidence, `LOG.md` 위치만 남긴다.

에러가 나면 먼저 Task별 `LOG.md`에 원문을 남기고, 해결되면 루트
`.harness/LESSONS.md`에 재발 방지 요약을 추가한다. `LOG.md`만 남기면 다음 세션이
"왜"를 다시 찾아야 하고, `LESSONS.md`만 남기면 실제 에러 메시지가 사라져 재현이
어렵다.

---

## Task별 `LOG.md` 실제 형식

```markdown
# LOG.md — Task 4.12 작업·에러 로그

## 2026-07-08

- 무엇을 시도했고 어떤 결과가 났는지 시간순으로 기록한다.
- 실패한 명령:
  `python3 scripts/example.py`
- 에러 원문:
  `ValueError: example`
```

날짜 헤더 아래 불릿으로 그날의 작업·에러를 쌓는다. 에러는 "무엇을 시도했고
무엇이 실패했는지"를 있는 그대로 적는다.

---

## `LESSONS.md` 실제 형식

```markdown
# LESSONS.md — 재발 방지 기록

## 2026-07-08 — Task status 변경은 Task ID context와 함께 패치할 것

- `tasks/index.json`에는 `"status": "todo"` 같은 반복 문자열이 많다.
- 예방 규칙: status 패치는 반드시 `"id": "{task-id}"`와 title/acceptance 일부를
  포함한 context hunk로 적용하고, 직후 대상 Task 상태를 확인한다.
```

각 항목은 **상황 → 왜 문제였는지 → 다음엔 어떻게 판단할지** 순서로 쓴다.
"CLAUDE.md 반영: 불필요/완료" 한 줄을 붙여, 일회성 판단 습관인지 항상 지킬
규칙으로 승격됐는지 구분한다.

---

## 언제 승격하는가

같은 유형의 실수가 두 번째 발생했거나, 프로젝트 전체에 적용되는 원칙이면
`CLAUDE.md`로 승격한다. Task 하나에만 해당하는 세부 이력은 해당 Task 디렉토리에
남기고, 다른 Task에서도 반복될 수 있는 판단 규칙만 `LESSONS.md`에 남긴다.

---

## 기록 프롬프트

```text
If an error occurs, log the raw command and error message in
.harness/tasks/<task-key>/LOG.md.
Once fixed, summarize the cause and a prevention rule in .harness/LESSONS.md.
If it should always apply going forward, also update CLAUDE.md.
```

```text
에러가 발생하면 실패한 명령과 에러 메시지를 원문 그대로
.harness/tasks/<task-key>/LOG.md에 남겨줘.
해결되면 원인과 재발 방지 규칙을 .harness/LESSONS.md에 요약해줘.
항상 지켜야 할 규칙이면 CLAUDE.md에도 반영해줘.
```

---

## 참고

- [../README.md](../README.md#error-memory--반복-실패-방지) — 요약
- [session-recovery.md](./session-recovery.md) — `.harness/tasks/` 기반 읽는 순서
- [../CLAUDE.md](../CLAUDE.md) — 상태 문서 규칙 원본
