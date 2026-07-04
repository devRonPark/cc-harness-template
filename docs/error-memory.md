# Error Memory — 반복 실패 방지 규칙

에러를 숨기지 않고 기록해서, 같은 실수를 같은 원인으로 두 번 반복하지 않게
하는 것이 `.harness/LOG.md`·`.harness/LESSONS.md`의 목적이다. 두 파일은
역할이 다르다 — 섞어 쓰지 않는다.

---

## `LOG.md`와 `LESSONS.md`의 차이

| | `LOG.md` | `LESSONS.md` |
|---|---|---|
| 성격 | append-only 작업·에러 일지 | 해결 후 재발 방지 요약 |
| 순서 | 위→아래로 추가만 (시간순) | 최신 항목이 위 |
| 내용 | 실패한 명령·에러 메시지 원문, 커밋 해시 | 원인 + "다음엔 어떻게 판단할지" |
| 분량 | 계속 누적 (아카이브하지 않음) | 최근 5개만 세션 시작 시 읽음 |
| 승격 | — | 항상 지킬 규칙이면 `CLAUDE.md`에도 반영 |

에러가 나면 먼저 `LOG.md`에 원문을 남기고, 해결되면 `LESSONS.md`에 요약을
추가한다 — 둘 다 해야 한다. `LOG.md`만 남기면 다음 세션이 "왜"를 다시
찾아야 하고, `LESSONS.md`만 남기면 실제 에러 메시지가 사라져 재현이 어렵다.

---

## `LOG.md` 실제 형식

```markdown
# LOG.md — 작업·에러 로그 (append-only)

> 시간 역순 아님 — 위에서 아래로 추가만 한다. 에러는 숨기지 말고 원문 그대로 기록.
> 해결된 에러는 재발 방지 관점에서 LESSONS.md에도 요약을 남긴다.

## 2026-07-04

- Task 2.7 — GitHub 연동 E2E 검증. ...
  에러 1건: 충돌 해소 정규식이 Plans.md 행 2개 삭제 → Read 확인 후 복원, LESSONS 기록.
  에러 2건: 훅이 git push 복합 명령을 force-push로 오탐 차단 → 명령 분리로 해결.
```

날짜 헤더 아래 불릿으로 그날의 작업·에러를 쌓는다. 에러는 "무엇을 시도했고
무엇이 실패했는지"를 있는 그대로 적는다 — 각색하지 않는다.

## `LESSONS.md` 실제 형식

```markdown
# LESSONS.md — 재발 방지 기록

> 에러·실수를 해결한 뒤 "다음에 같은 실수를 안 하려면"을 한 항목으로 남긴다.
> 최신 항목이 위. 세션 재개 시 최근 5개를 먼저 읽는다.
> 항상 지켜야 할 규칙으로 승격되면 CLAUDE.md에도 반영하고 여기 표시한다.

## 2026-07-04 — Week 3 감사 빈틈 개선 (H1~H5·M1~M8 실증)

- **GitHub Free 플랜 private repo는 branch protection/rulesets API가 403.**
  harness-gh-test(private)에서 branch protection 테스트 시도 → 즉시 확인.
  다음에 이런 검증 필요하면 이 제약을 먼저 확인하고 사용자에게 public 전환
  여부를 물을 것(자동으로 켜지 말 것).
```

각 항목은 **상황 → 왜 문제였는지 → 다음엔 어떻게 판단할지** 순서로 쓴다.
"CLAUDE.md 반영: 불필요/완료" 한 줄을 붙여, 일회성 판단 습관인지 항상
지킬 규칙으로 승격됐는지 구분한다(예: 2026-07-03 "세션 모니터 스냅샷은
stale일 수 있다" 항목은 "CLAUDE.md 반영: 불필요"로 남겼다 — 규칙화할
정도는 아니라고 판단했기 때문).

---

## 언제 승격하는가

같은 유형의 실수가 **두 번째** 발생했거나, 프로젝트 전체에 적용되는 원칙이면
`CLAUDE.md`로 승격한다. 예: "에러는 숨기지 말고 LOG.md에 원문 기록, 해결하면
LESSONS.md에 재발 방지 항목 추가"는 이 템플릿에서 실제로 CLAUDE.md
상태 문서 규칙 섹션에 반영된 규칙이다. 일회성 판단(예: 세션 모니터 신뢰도)은
승격하지 않고 LESSONS.md에만 남긴다 — 모든 걸 규칙화하면 CLAUDE.md가
비대해져 컨텍스트만 잡아먹는다.

---

## 기록 프롬프트

```text
If an error occurs, log the raw command and error message in .harness/LOG.md.
Once fixed, summarize the cause and a prevention rule in .harness/LESSONS.md.
If it should always apply going forward, also update CLAUDE.md.
```

```text
에러가 발생하면 실패한 명령과 에러 메시지를 원문 그대로 .harness/LOG.md에 남겨줘.
해결되면 원인과 재발 방지 규칙을 .harness/LESSONS.md에 요약해줘.
항상 지켜야 할 규칙이면 CLAUDE.md에도 반영해줘.
```

---

## 참고

- [../README.md](../README.md#error-memory--반복-실패-방지) — 요약
- [session-recovery.md](./session-recovery.md) — `.harness/` 전체 읽는 순서
- [../CLAUDE.md](../CLAUDE.md) — 상태 문서 규칙 원본
