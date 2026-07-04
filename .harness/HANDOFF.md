# HANDOFF.md — 다음 세션 인수인계

> 세션 종료(또는 끊김 대비) 시점에 갱신. 다음 세션이 전체 파일을 다시 읽지 않고
> 여기 적힌 최소 파일만 읽고 바로 이어가게 하는 것이 목적.

## 다음 세션이 먼저 읽을 최소 파일

1. `.harness/STATE.md` — 현재 상태
2. `.harness/LESSONS.md` — 최근 5개 항목
3. `Plans.md` — Task 상태 (cc:WIP 행 확인)

## 재개 지점

- Week 3 전 Task(3.1~3.12) 완료 + 커밋 + push까지 끝난 상태. 진행 중인
  작업 없음.
- 이번 세션에서 발견한 새 사실(문서에 반영 완료, 여기는 참고용 요약):
  - branch protection 켜진 private repo는 GitHub Free 플랜에서 API 자체가
    403 — H1 실증을 위해 harness-gh-test를 잠깐 public 전환했다가 검증 후
    원복함(사용자 승인받음).
  - plans-complete의 PR 폴백이 동작하려면 저장소 설정 2개가 별도로 켜져야
    함(Actions PR 생성 허용, Allow auto-merge) — 둘 다 기본값 꺼짐, 실증
    중 실제로 막혀서 발견. `plans-complete.yml` 주석에 명시함.
- 다음 세션에서 판단할 것: Week 4 스코프 — 남은 후보는 template-audit.md의
  L1~L5(백로그, granularity vague_re 오탐, test-agent pretest 오매칭 등)와
  M8에서 명시한 대로 "SHA 강제 핀"은 여전히 미지원(YAGNI 보류 상태 유지 중).

## 주의사항

- Task 상태는 Plans.md가 단일 출처 — `.harness/TASKS.md`에 Task 상태를 복제하지 말 것.
- harness-gh-test repo는 private + branch protection 해제 상태로 복원됨 —
  다시 H1류 검증이 필요하면 이 순서(public 전환 승인 → protection 설정
  승인 → 검증 → 전부 원복)를 다시 밟을 것, 자동화하지 말고 매번 확인받을 것.
