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

## 2026-07-04 (계속) — README 고도화 + 백로그 정리

- README.md 전면 개편: Why·What You Get·Quick Start·Claude Code Setup·
  기존 프로젝트에 적용·Recommended Workflow·Commands·Hooks·Session Recovery·
  Error Memory·Philosophy·Contributing·License 섹션 추가. 기존 정확한 내용
  (플러그인 표, 파일 구조, 워크플로우, 치트시트, 버전 SHA)은 유지·재배치만 함.
  없는 파일(ADR.md·verify-harness.sh·.claude/commands/)은 지어내지 않고
  "미포함"으로 명시.
- docs/claude-code-hooks.md·session-recovery.md·error-memory.md 3개 신설 —
  README 요약을 실제 파일 형식 기준으로 심화.
- 사용자 요청으로 템플릿 완결성 재감사 실시. docs/specs/2026-07-04-template-audit.md의
  L1~L5가 Plans.md에 Task로 전환된 적 없이 백로그로만 남아 있음을 확인
  (grep으로 실코드 재검증: vague_re 정규식 여전히 `(전체|모든| 및 |그리고)`,
  test-agent.md:40 `grep -q '"test"'` 여전히 pretest 오탐 가능, CONTEXT_INDEX.md가
  존재하지 않는 docs/PRD.md 등 인덱싱, harness.toml의 `rm -r` 패턴이
  `rm -fr`/`rm -R` 미포착 — 전부 실제로 확인됨).
- 세션 자체 점검 중 발견: README 개편 + docs 3개 신설이라는 작업 단위가
  끝났는데도 `.harness/STATE.md`·`CONTEXT_INDEX.md`를 갱신하지 않은 채
  다음 요청을 받음 — CLAUDE.md 상태 문서 규칙 위반. 이번에 STATE.md·
  CONTEXT_INDEX.md·LOG.md를 갱신해 바로잡음.
- L1~L5를 Plans.md Week 4 Task 4.1~4.6으로 등록(cc:TODO) — 계획 단계만
  진행, 실제 수정은 /harness-work로 별도 진행 예정. 세분화 기준
  (agents/task-decomposer.md) 통과 확인: 파일당 단일 관심사, grill-me 관련
  2건(산출 경로 인자·headless 모드)은 관심사가 달라 4.5·4.6으로 분리.

## 2026-07-08 — Planning observability v1

- 사용자 요청으로 독립 task-decomposer proposal 기본 흐름과 비개발자 친화 planning
  JSONL 감시 구조 구현. `docs/specs/2026-07-08-planning-observability.md`에
  계획 문서 저장.
- `.harness/shared/planning/runs/`와 `.harness/events/` 골격 추가, skeleton에도
  반영해 `init.sh` 복사 대상에 포함.
- planning 전용 스크립트 추가:
  `planning_log.py`, `build_planning_context.py`, `run_task_decomposer.py`,
  `validate_task_proposal.py`, `apply_task_proposal.py`.
- 문서 규약 갱신: `agents/task-decomposer.md`, `CLAUDE.md`, `BLUEPRINT.md`,
  `README.md`, `docs/session-recovery.md`, `.harness/CONTEXT_INDEX.md`,
  `templates/skeleton/.harness/CONTEXT_INDEX.md`, `harness.toml`.
- 검증: `python3 -m unittest tests.test_tasks tests.test_planning -v` PASS(18),
  `python3 scripts/validate_tasks.py` PASS, `python3 scripts/sync_plans.py --check` PASS,
  `init.sh` smoke test PASS.

## 2026-07-08 — Codex repo-scoped harness skills

- 사용자 제공 계획에 따라 `.agents/skills/` 아래 Codex skill 6종 추가:
  `grill-me`, `harness-plan`, `harness-work`, `harness-review`,
  `harness-progress`, `harness-sync`.
- `AGENTS.md`, `README.md`, `BLUEPRINT.md`를 `$grill-me`/`$harness-*` 호출
  방식으로 갱신하고, `init.sh`가 `.agents/skills`와 planning proposal scripts를
  새 프로젝트에 복사하도록 수정.
- `.agents/skills` 디렉터리가 샌드박스에서 read-only로 잡혀 최초 `mkdir -p`가
  `Read-only file system`으로 실패. 승인된 escalated command로 디렉터리를 생성한
  뒤 `apply_patch`로 파일을 추가해 해결.
- 검증: skill 6개 존재 확인, frontmatter 확인, `python3 scripts/validate_tasks.py`
  PASS, `python3 scripts/validate_tasks.py --root templates/skeleton` PASS,
  `python3 scripts/sync_plans.py --check` PASS, skeleton sync check PASS,
  `init.sh /tmp/cc-harness-skill-test.iB2C65` smoke test PASS,
  `python3 -m unittest tests.test_tasks tests.test_planning -v` PASS(18).

## 2026-07-08 — Git workflow helper command/skill

- Claude Code local custom command 3종 추가:
  `.claude/commands/branch-checkout.md`, `.claude/commands/git-push.md`,
  `.claude/commands/pr-create.md`.
- Codex repo-scoped skill 3종 추가:
  `.agents/skills/branch-checkout/SKILL.md`, `.agents/skills/git-push/SKILL.md`,
  `.agents/skills/pr-create/SKILL.md`.
- 각 절차는 `git status`와 현재 브랜치를 먼저 확인하고, local changes discard와
  force push를 금지하도록 작성.
- `init.sh`, `README.md`, `BLUEPRINT.md`, `AGENTS.md`, `docs/setup-guide.md`,
  context index, `tasks/index.json`, `Plans.md` 갱신.
- 검증: skill frontmatter PASS, command 파일 존재 확인 PASS,
  `python3 scripts/validate_tasks.py` PASS, skeleton validate PASS,
  `python3 scripts/sync_plans.py --check` PASS, skeleton sync check PASS,
  `python3 -m unittest tests.test_tasks tests.test_planning -v` PASS(18),
  `init.sh /tmp/cc-harness-git-helper-test.9j00Yd` smoke test PASS.
## 2026-07-08 12:20 KST — Task status patch target mistake

- 상황: Task `4.10`을 완료 처리하려고 `"status": "todo"` 단일 패턴을 패치했더니
  첫 번째 TODO였던 `4.1`이 잘못 `done`으로 변경됐다.
- 원인: `apply_patch` context가 Task ID를 포함하지 않아 동일한 status 문자열 중
  첫 매칭에 적용됐다.
- 조치: `grep -n '"id": "4\.' -A7 tasks/index.json`으로 상태를 확인했고,
  `4.1`은 `todo`로 복구, `4.10`만 `done`으로 전환했다.
- 검증: `python3 scripts/sync_plans.py`, `python3 scripts/validate_tasks.py`,
  `python3 scripts/sync_plans.py --check`, 전체 unittest 재실행 모두 PASS.
