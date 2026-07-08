# Session Recovery — 세션 복구 절차 심화

터미널 세션은 언제든 끊긴다는 전제로 이 템플릿을 만들었다. `.harness/`는
그 전제에 대응하는 상태 문서 세트다. 이 문서는 README의
[Session Recovery](../README.md#session-recovery) 요약을 실제 파일 단위로 풀어 쓴다.

---

## 읽는 순서 (고정)

CLAUDE.md 상태 문서 규칙에 박혀 있는 순서 — 이 순서를 바꾸지 않는다.

1. **`.harness/STATE.md`** — 현재 상태 스냅샷. "지금 목표가 뭐고 어디까지 왔는지"를
   한 파일로 복원하는 용도.
2. **`.harness/LESSONS.md`** — 최근 5개 항목만. 전체를 다 읽지 않는다 — 오래된
   교훈까지 매번 다시 읽으면 토큰만 쓰고 최신 맥락에 못 미친다.
3. **`tasks/index.json`** — Task 상태 단일 출처. `wip` Task가 있으면 그게 재개 지점.
4. **`Plans.md`** — 사람이 읽는 snapshot. stale일 수 있으며 Task 표를 직접 편집하지 않는다.
5. 그 다음은 **필요할 때만**, `.harness/CONTEXT_INDEX.md`로 골라서:
   - `.harness/HANDOFF.md` — 직전 세션이 남긴 인수인계. 재개 직후 1회만 읽는다.
   - `.harness/TASKS.md` — 현재 Task의 세션 체크리스트 (Task보다 작은 단위).
   - `.harness/LOG.md` — 에러 이력 조회가 필요할 때만.
   - `.harness/CHECKPOINTS.md` — 커밋 이력 추적이 필요할 때만.
   - `.harness/events/planning.jsonl` — `/harness-plan` 단계 실패·반영 흐름을
     감시해야 할 때만.
   - `.harness/shared/planning/latest.json` — 최신 planning run의
     context/proposal/report 위치가 필요할 때만.

**목적 없이 전체 파일을 다시 읽지 않는다** — CONTEXT_INDEX.md가 이 선별을 위해 존재한다.

---

## 파일별 역할 (겹치지 않게 나뉜다)

| 파일 | 역할 | 갱신 시점 |
|------|------|-----------|
| `STATE.md` | 현재 스냅샷 (목표, 진행 중 Task, 마지막 검증 결과) | 작업 시작 전·단위 종료 후 |
| `HANDOFF.md` | 다음 세션이 최소한으로 읽을 것 + 재개 지점 + 주의사항 | 세션 종료 시(또는 끊김 대비) |
| `TASKS.md` | 현재 Task 하나의 세션 체크리스트 | Task 착수·완료 시 |
| `LOG.md` | 작업·에러 append-only 로그 | 매 작업/에러 발생 시 |
| `LESSONS.md` | 재발 방지 기록 | 에러 해결 후 |
| `CHECKPOINTS.md` | 작업 단위 완료 + 커밋 해시 | 커밋할 때마다 |
| `CONTEXT_INDEX.md` | 위 파일들의 역할·읽는 시점 인덱스 | 새 파일 추가/역할 변경 시 |
| `events/planning.jsonl` | `/harness-plan` 단계별 감시 이벤트 | planning 실패·반영 흐름 추적 시 |
| `shared/planning/runs/` | run별 context/proposal/report 작업대 | planning proposal 확인 시 |

**Task 상태의 단일 출처는 `tasks/index.json`이다.** `Plans.md`는 사람이 필요할 때 여기서 생성하는 snapshot이다.
`.harness/TASKS.md`에 Task 상태를
복제하지 않는다 — 복제하면 두 파일이 어긋났을 때 뭘 믿을지 애매해진다.

---

## 실제 파일 형식

`TASKS.md`는 Task 착수 전엔 비어 있다:

```markdown
## 현재 Task: 없음

(아직 착수 전 — Task 착수 시 여기에 체크리스트 작성.)
```

`CHECKPOINTS.md`는 표 형식으로 누적한다:

```markdown
| 일시 | Task | 내용 | 커밋 | 검증 |
|------|------|------|------|------|
| 2026-07-04 | 1.4 | .harness/ 골격 7종 추가 | `a4c6ef1` | Acceptance PASS |
```

---

## 여러 프로젝트를 동시에 운영할 때

이 템플릿을 여러 프로젝트에 각각 적용하면 `.harness/`도 프로젝트마다 독립적으로
생긴다 — 공유하지 않는다. 프로젝트 A의 `STATE.md`가 프로젝트 B의 재개에
영향을 주지 않는다. 여러 프로젝트를 오갈 땐 세션 시작 시 "지금 어느 디렉토리에
있는지"부터 확인하는 습관이 중요하다 — `.harness/STATE.md`의 "현재 목표"가
지금 열려 있는 프로젝트와 일치하는지 첫 응답에서 검증한다.

---

## 모니터/훅이 주는 상태 요약은 참고만

세션 시작 시 어떤 모니터나 훅이 "WIP 1건" 같은 요약을 보여줄 수 있다. 이 요약이
`tasks/index.json`·`git status`의 실제 상태와 어긋난 사례가 있었다(`.harness/LESSONS.md`
2026-07-03 항목). 요약은 참고만 하고, 판단은 항상 `tasks/index.json`과 `git status`
직접 확인으로 한다.

---

## 재개 프롬프트

```text
Read .harness/STATE.md, then the last 5 entries of .harness/LESSONS.md,
then tasks/index.json and Plans.md.
Resume from the last recorded state.
Do not repeat completed Tasks unless Acceptance requires re-verification.
Before continuing, summarize the current state and next action.
```

```text
.harness/STATE.md를 읽고, .harness/LESSONS.md 최근 5개 항목을 읽고,
tasks/index.json과 Plans.md를 읽어줘.
마지막으로 기록된 상태부터 작업을 재개해줘.
Acceptance 재검증이 필요한 경우가 아니면 이미 완료된 Task는 반복하지 마.
계속하기 전에 현재 상태와 다음 작업을 먼저 요약해줘.
```

---

## 참고

- [../README.md](../README.md#session-recovery) — 요약
- [error-memory.md](./error-memory.md) — `LOG.md`/`LESSONS.md` 작성 규칙
- [../CLAUDE.md](../CLAUDE.md) — 상태 문서 규칙 원본
