# HANDOFF.md — 다음 세션 인수인계

> 세션 종료(또는 끊김 대비) 시점에 갱신. 다음 세션이 전체 파일을 다시 읽지 않고
> 여기 적힌 최소 파일만 읽고 바로 이어가게 하는 것이 목적.

## 다음 세션이 먼저 읽을 최소 파일

1. `.harness/STATE.md` — 현재 상태
2. `.harness/LESSONS.md` — 최근 5개 항목
3. `Plans.md` — Task 상태 (cc:WIP 행 확인)

## 재개 지점

- Week 2 dogfooding 완료 (2.1~2.5 전부 cc:완료). **Week 2 변경분은 사용자
  지시로 커밋하지 않음** — Plans.md·LESSONS.md 수정분이 working tree에 있음.
- ../routine-saas/에 기획 산출물 생성 완료: PRD(검토 대기)·UserFlow·
  Architecture·Plans.md(Task 11개).
- 다음 작업: ① 사용자 PRD 검토 (성공 기준 잠정값 확정 필요)
  ② Week 3 후보 결정 — LESSONS.md의 템플릿 결함 2건 (init 스크립트, grill-me 경로 인자)

## 주의사항

- 커밋은 사용자 명시 요청 전까지 금지. routine-saas는 전면 커밋 금지.
- Task 상태는 Plans.md가 단일 출처 — .harness/TASKS.md에 Task 상태를 복제하지 말 것.
- CLAUDE.md 118줄 — 훅이 분할 권고. 스코프 확장이라 미실행, 사용자 판단 대기.
