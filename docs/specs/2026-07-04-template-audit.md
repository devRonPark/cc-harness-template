# 템플릿 감사 보고서 — 2026-07-04 회고

작성일: 2026-07-04
최종 갱신: 2026-07-08

이 문서는 2026-07-04 기준 GitHub 연동 설계를 감사해 Week 3 개선 Task를 만든
기록이다. 당시에는 GitHub Actions가 Task 상태 전환과 PR 상태 게이트를 함께
맡는 방향을 검토했으나, 2026-07-08 설계 변경으로 해당 방향은 폐기됐다.

현재 기준은 다음과 같다.

- `tasks/index.json`은 Task 상태의 단일 출처다.
- 세션 에이전트가 Acceptance와 관련 테스트 통과 후 Task 상태를 직접 갱신한다.
- `Plans.md`는 `python3 scripts/sync_plans.py`로 생성하는 읽기용 snapshot이다.
- GitHub Actions는 `ci.yml`의 기술 스택 CI와 `plans-guard.yml`의 manifest/snapshot
  검증만 수행한다.
- branch protection required check는 `ci-ok`, `plans-guard / tasks/index.json 검증`,
  `plans-guard / Plans.md sync 검증` 중심으로 둔다.

## 남은 교훈

- branch protection과 자동 쓰기 workflow를 섞으면 운영 복잡도가 급격히 커진다.
- PR 단계에서 Task 상태 정책을 모두 강제하려 하면 로컬-only 사용성과 GitHub 사용성이
  쉽게 갈라진다.
- 새 프로젝트 초기화는 `init.sh`와 `templates/skeleton/`을 통해 dogfood 이력 없는
  깨끗한 골격을 복사해야 한다.
- `ci-ok`처럼 이름이 고정된 요약 check를 required check로 등록해야 스택 변경 시
  branch protection이 깨지지 않는다.

상세 DoD·Acceptance·Depends는 현재 `tasks/index.json`과 생성된 `Plans.md`를 SSOT로
본다.
