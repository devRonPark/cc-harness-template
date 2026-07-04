# LOG.md — 작업·에러 로그 (append-only)

> 시간 역순 아님 — 위에서 아래로 추가만 한다. 에러는 숨기지 말고 원문 그대로 기록.
> 해결된 에러는 재발 방지 관점에서 LESSONS.md에도 요약을 남긴다.

## 2026-07-03

- Task 1.3 커밋 (`a32df79`) — task-decomposer + 세분화 게이트. Acceptance PASS.
- .gitignore 정리 커밋 (`9c05093`) — 플러그인 런타임 산출물 제외.
- Task 1.4 착수 — .harness/ 상태 문서 체계 추가.
  참고: 세션 재개 프롬프트가 .harness/ 문서를 전제했으나 저장소에 부재 →
  사용자 승인 받아 템플릿 정식 기능으로 추가.
- Task 1.4 완료 — .harness/ 골격 7종 + CLAUDE.md 상태 문서 규칙. Acceptance PASS.
  미커밋 (사용자 요청 대기). 훅 경고: CLAUDE.md 118줄 분할 권고 → 미실행, HANDOFF에 기록.
- Task 1.4 커밋 (`a4c6ef1`) — 사용자 승인.
- Week 2 dogfooding (2.1~2.5, 커밋 금지 지시) — ../routine-saas/ 골격 생성,
  grill-me 인터뷰 4문항 확정(실행 도구·직장인·코어 3종·PWA+웹푸시), 5번째(성공 기준)
  무응답 → 권장값 잠정 적용. PRD·UserFlow·Architecture·Plans.md(Task 11개) 산출.
  템플릿 결함 2건 발견 → LESSONS.md 기록.
- Task 2.6 — DESIGN.md 기획 산출물 추가 (사용자 지적: 디자인 산출물 누락).
  templates/DESIGN.md 골격 + CLAUDE.md 기획 규칙 + routine-saas 실제 작성 +
  UI Task(2.1·2.3) Depends 게이트 연결. 훅 경고: CLAUDE.md 123줄 (분할 권고 지속).

## 2026-07-04

- 템플릿 커밋 `6a51ad0` + origin push (Task 2.6분).
- Task 2.7 — GitHub 연동 E2E 검증. devRonPark/harness-gh-test(private) 생성,
  Milestone 1 + Issue #1·#2, PR 4개로 시나리오 A~D 검증 → plans-guard 3잡 전부
  기대대로. 빈틈 7건 도출 (LESSONS 참고). plans-complete.yml 신설·실증.
  에러 1건: 충돌 해소 정규식이 Plans.md 행 2개 삭제 → Read 확인 후 복원, LESSONS 기록.
  에러 2건: 훅이 git push 복합 명령을 force-push로 오탐 차단 → 명령 분리로 해결.
- docs/specs/2026-07-04-template-audit.md 작성 — 전 파일 정독 감사, H1~H5·
  M1~M8·L1~L5 도출. Plans.md Week 3 Task 3.1~3.12로 매핑 후 커밋(`37e1997`).
- Week 3 순차 실행 (3.1 → 3.2 → 3.3 → 3.6 → 3.4 → 3.5 → 3.7 → 3.8 → 3.9 →
  3.10 → 3.11 → 3.12, Depends 순서 기준):
  - 3.1(H1): plans-complete push→PR 폴백 설계. harness-gh-test를 사용자 승인
    받아 public 임시 전환 + branch protection 실제 설정 후 검증 — GitHub Free
    플랜은 private repo에 branch protection/rulesets API 자체가 403이라는
    사실을 실증 중 발견(LESSONS 기록). PR 생성도 저장소 설정
    ("Allow GitHub Actions to create and approve pull requests") 기본값 꺼짐
    때문에 최초 실패 → 켜서 통과. auto-merge도 동일하게 "Allow auto-merge"
    꺼짐으로 실패 → 수동 merge로 최종 flip 확인. 검증 후 전부 원복.
  - 3.2(H5): templates/skeleton/ 신설(Plans.md + .harness/ 7종, dogfood
    이력 0건 확인).
  - 3.3(H5): init.sh 작성, 스크래치 디렉토리에 실제 실행해 검증.
  - 3.6(M1·M7): header-check 잡 신설, 정상/컬럼 누락 케이스 로컬 검증.
  - 3.4(H2): plans-diff-check 잡 신설, 비-task 브랜치·task 브랜치 타 행 변경
    2종 시나리오를 harness-gh-test에서 실제 PR로 재현·검증.
  - 3.5(H3): depends-check 잡 신설, 미완료 Depends 시나리오 실제 PR 검증.
  - 3.7(M3): README·BLUEPRINT의 완료 전환 서술을 GitHub 연동/미연동 모드별로
    명확히 구분.
  - 3.8(M4): harness.toml 죽은 키(max_iterations 등) 제거, 섹션 주석 SSOT
    역할 반전 명시. harness sync 산출물(.claude-plugin/)이 untracked인 것을
    발견해 .gitignore 추가.
  - 3.9(M2): Task 0.4의 "|| echo skip"과 Week 2 행들의 ../routine-saas/
    경로를 Acceptance "-"로 교정, 범례에 anti-pattern 금지 규약 추가.
  - 3.10(M5): agents/*.md가 실제 서브에이전트가 아님을 BLUEPRINT·README에
    명시, .claude/agents/ 이전은 보류 결정(근거 기록).
  - 3.11(M6): ci-ok 요약 잡 신설, harness-gh-test에서 실제 PR로 실행 검증.
  - 3.12(M8): README 플러그인 버전 표에 확인된 SHA·확인일 컬럼 + 업데이트
    전 확인 절차 추가.
  - 사용자 요청으로 README.md·docs/github-integration.md 추가 갱신 —
    github-integration.md가 예전 3잡 구성을 서술하고 "완료를 PR 마지막
    커밋에 포함시켜도 된다"는, CLAUDE.md·plans-diff-check와 모순되는 안내를
    담고 있어서 함께 교정(`930e404`).
