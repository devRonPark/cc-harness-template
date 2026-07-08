# LESSONS.md — 재발 방지 기록

> 에러·실수를 해결한 뒤 "다음에 같은 실수를 안 하려면"을 한 항목으로 남긴다.
> 최신 항목이 위. 세션 재개 시 최근 5개를 먼저 읽는다.
> 항상 지켜야 할 규칙으로 승격되면 CLAUDE.md에도 반영하고 여기 표시한다.

## 2026-07-07 — README 환경 구성 절차 팩트 체크

- **Plugin 버전 표는 "확인일" 이후 바로 stale해진다.** ponytail이 확인일
  (2026-07-04, SHA `40e50d9`) 대비 3일 만에 `1b2760d`로 갱신됨 — GitHub API로
  각 마켓플레이스 repo의 `plugin.json`/HEAD sha를 직접 조회해서야 발견했다.
  README 자체가 "설치는 항상 최신 커밋"이라고 명시하니, 표 값을 코드 근거
  없이 신뢰하지 말고 팩트 체크 요청이 오면 항상 GitHub API로 재확인할 것.
- **버전 번호와 SHA는 따로 드리프트할 수 있다.** claude-code-harness는 SHA는
  일치(`c220671`)했지만 표의 버전(4.16.3)이 실제 `plugin.json`(4.16.4)과
  달랐다 — SHA만 맞다고 버전도 맞다고 가정하면 안 된다.
- **"저장소에 실제로 있는 파일 기준"이라 적어놓고 누락된 파일이 있었다.**
  `docs/specs/*.md` 2개가 파일 표·트리 어디에도 없었다 — 완전성을 주장하는
  문서를 고칠 때는 `find`로 실제 트리와 diff를 떠서 누락을 확인할 것.

## 2026-07-04 — Week 3 감사 빈틈 개선 (H1~H5·M1~M8 실증)

- **GitHub Free 플랜 private repo는 branch protection/rulesets API가 403.**
  harness-gh-test(private)에서 branch protection 테스트 시도 → "Upgrade to
  GitHub Pro or make this repository public" 즉시 확인. protection 관련
  기능을 검증하려면 테스트 repo를 임시 public 전환하거나 유료 플랜이 필요 —
  감사 문서 작성 시점엔 이 제약을 몰랐음. 다음에 이런 검증 필요하면 이 제약을
  먼저 확인하고 사용자에게 public 전환 여부를 물을 것(자동으로 켜지 말 것 —
  실제로 이번엔 AskUserQuestion으로 승인받음).
- **plans-complete의 PR 폴백은 저장소 설정 2개에 암묵적으로 의존한다.**
  "Allow GitHub Actions to create and approve pull requests"와
  "Allow auto-merge"가 둘 다 기본값 꺼짐 — 실제로 폴백 코드를 짜고 나서야
  실행 중 발견했다(설계만으로는 안 보임). 자동화 코드가 gh CLI로 PR
  생성·머지를 시도하는 워크플로를 짤 때는 이 두 설정을 먼저 켜져 있는지
  확인하거나, 실패 시 폴백 메시지로 명확히 안내할 것 — 이번엔 후자로 처리.
- **문서 갱신은 원본만 고치면 안 된다 — 링크된 상세 가이드까지 같이 확인.**
  M3에서 README·BLUEPRINT의 완료 전환 서술을 고쳤지만, README가 링크하는
  docs/github-integration.md는 그보다 더 오래된 서술(placeholder를 required
  check로 등록하라, 완료를 PR 안에서 처리해도 된다)을 갖고 있어 사용자가
  "README도 갱신해달라"고 재요청한 뒤에야 발견했다. 다음엔 문서 하나를
  고칠 때 그 문서가 참조하는 다른 문서까지 grep으로 훑어 모순 여부를 먼저
  확인할 것.

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
## 2026-07-08 — Task status 변경은 Task ID context와 함께 패치할 것

- `tasks/index.json`에는 `"status": "todo"` 같은 반복 문자열이 많다. 상태를 바꿀 때
  단일 status 줄만 패치하면 다른 Task가 변경될 수 있다.
- 예방 규칙: status 패치는 반드시 `"id": "{task-id}"`와 title/acceptance 일부를
  포함한 context hunk로 적용하고, 직후 `grep -n '"id": "{task-id}"' -A8`로 대상
  Task 상태를 확인한다.
