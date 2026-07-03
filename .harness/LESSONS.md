# LESSONS.md — 재발 방지 기록

> 에러·실수를 해결한 뒤 "다음에 같은 실수를 안 하려면"을 한 항목으로 남긴다.
> 최신 항목이 위. 세션 재개 시 최근 5개를 먼저 읽는다.
> 항상 지켜야 할 규칙으로 승격되면 CLAUDE.md에도 반영하고 여기 표시한다.

## 2026-07-04 — GitHub 연동 E2E 검증 (harness-gh-test repo)

- **검증 통과**: plans-guard 3잡 모두 기대대로 — 정상 PR은 3잡 PASS, WIP 누락은
  wip-branch-check만 FAIL, 뭉뚱그린 Task는 granularity만 FAIL, acceptance 실패는
  oracle만 FAIL. 시나리오 간 오검출 없음.
- **빈틈 1·2 (높음, 해결)**: 머지 후 cc:WIP가 main에 영구 잔류 → 후속 모든 PR이
  남의 Task acceptance를 재실행 (PR #4 로그로 실증). PR 안에서 완료로 바꾸면
  wip-branch-check와 모순이라 수동 해결 불가 → `plans-complete.yml` 신설
  (머지 이벤트에 bot이 cc:완료 커밋). 테스트 repo에서 자동 flip 실증 완료.
- **빈틈 3~6 (중·낮, 문서화로 해결)**: branch protection 없으면 main 직접 push로
  전 게이트 우회 / Milestone은 gh api 필요 / 커밋 메시지 task-id 규약 부재 /
  PR body "Closes #N" 규약 부재 → CLAUDE.md GitHub 플로우에 전부 명문화.
- **빈틈 7 (중, 문서화)**: Plans.md 공유 테이블 특성상 병렬 브랜치 간 머지 충돌
  빈발 — "PR 전 main 머지" 규약 추가. 구조적 해결(Task별 파일 분리)은 YAGNI 기각.
- **부수 교훈**: 충돌 해소를 정규식 일괄 치환으로 하면 양쪽 행이 통째로 날아갈 수
  있다 — 충돌 마커는 Read로 눈으로 확인 후 행 단위로 복원할 것 (이번에 실제 발생,
  즉시 복구).

## 2026-07-03 — dogfooding에서 발견한 템플릿 결함 (Week 3 후보)

- **결함 1 — 신규 프로젝트 초기화가 전부 수동.** README cp 목록에 .harness/ 골격이
  없고, 템플릿 저장소의 .harness/·Plans.md는 실제 dogfood 상태가 들어 있어 그대로
  복사할 수 없다. 이번엔 수동으로 초기 상태 버전을 다시 작성했다.
  → Week 3 후보: 초기화 스크립트(init.sh) 또는 clean 골격 세트(templates/) 분리.
- **결함 2 — grill-me가 대상 디렉토리 지정을 공식 지원 안 함.** 다른 프로젝트의
  PRD를 쓰려면 args로 산출 경로를 우회 전달해야 했다.
  → Week 3 후보: SKILL.md에 산출 경로 인자 규약 추가.
- **결함 3 — 기획 파이프라인에 디자인 산출물이 없었다 (사용자 지적, 해결됨).**
  UI Task가 있는데 디자인 기준 문서가 없으면 worker가 Task마다 색·간격·톤을
  즉흥 결정 → 화면 간 일관성 붕괴. AI 에이전트 구현일수록 심해짐.
  → Task 2.6으로 해결: docs/templates/DESIGN.md 골격 + CLAUDE.md 기획 규칙
  (UI Task는 DESIGN.md를 Depends로 게이트). 툴 강제(CI lint)는 위반이 실제
  발생하면 도입 — Atlassian식 자체 툴은 YAGNI.
- **잘 작동한 것**: grill-me의 "무응답 시 확정분으로 초안 + Open Questions" 규칙,
  task-decomposer 세분화 기준(R1~R7 → 11개 단일 관심사 Task로 자연 분해).

## 2026-07-03 — 상태 문서 부재를 가정으로 덮지 말 것

- **상황**: 세션 재개 프롬프트가 `.harness/` 상태 문서를 전제했으나 저장소에 없었다.
- **교훈**: 요청이 전제한 파일이 없으면 임의 생성하지 말고 먼저 보고한다 —
  없는 구조를 만드는 건 스코프 결정이므로 사용자 확인 후 진행. (이번엔 확인 후 생성)
- **CLAUDE.md 반영**: 상태 문서 규칙 섹션으로 반영됨.

## 2026-07-03 — 세션 모니터 스냅샷은 stale일 수 있다

- **상황**: 세션 시작 모니터가 "WIP 1건"이라 보고했으나 Plans.md에 cc:WIP 없었다.
- **교훈**: 모니터/훅이 주는 상태 요약은 참고만 하고, 실제 상태는 Plans.md와
  `git status`로 직접 확인한 뒤 판단한다.
- **CLAUDE.md 반영**: 불필요 (일회성 판단 습관).
