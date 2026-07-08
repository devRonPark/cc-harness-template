# Plans.md — [PROJECT_NAME]

작성일: YYYY-MM-DD
기준 문서: docs/PRD.md

---

## 완료된 작업

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 0.1 | PRD 작성 (`/grill-me` 인터뷰) | docs/PRD.md v0.1 존재, Open Questions 정리됨 | test -f docs/PRD.md | - | cc:완료 | - |
| 0.2 | 기획 보완 문서 | UserFlow.md·Architecture.md 작성 (docs/templates/ 골격 사용) | test -f docs/UserFlow.md && test -f docs/Architecture.md | 0.1 | cc:완료 | - |
| 0.3 | Harness 초기화 | harness doctor 전체 통과, CLAUDE.md·Plans.md 존재 | test -f CLAUDE.md && test -f Plans.md && test -f harness.toml | - | cc:완료 | - |
| 0.4 | Plugin 설정 | ponytail·caveman·VFF 설치 확인, agent MEMORY.md 3개 존재 | - | 0.3 | cc:완료 | - |

---

## Week 1 — 템플릿 개선

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 1.0 | Plans.md 템플릿 개선 | bootstrap Task에 Acceptance 예시 있음, 현실적 샘플 Task 포함 | grep -qE 'test -f\|npm test\|pytest\|go test\|curl' Plans.md | - | cc:완료 | - |
| 1.1 | test agent 추가 | agents/test-agent.md 존재, harness.toml [test] 섹션, BLUEPRINT.md 업데이트 | test -f agents/test-agent.md | - | cc:완료 | - |
| 1.2 | 기획 파이프라인 추가 | grill-me 스킬 + docs/templates/ 골격 3종, CLAUDE.md 기획 규칙 | test -f .claude/skills/grill-me/SKILL.md && test -f docs/templates/PRD.md | - | cc:완료 | - |
| 1.3 | task-decomposer + 세션 세분화 게이트 추가 | agents/task-decomposer.md 존재, harness.toml [plan] 섹션, CLAUDE.md 구현 규칙에 세분화 게이트 명시 | test -f agents/task-decomposer.md && grep -q '세분화 게이트' CLAUDE.md | 1.1 | cc:완료 | - |
| 1.4 | .harness/ 상태 문서 체계 추가 | .harness/ 골격 7종(STATE·HANDOFF·TASKS·LOG·LESSONS·CHECKPOINTS·CONTEXT_INDEX) 존재, CLAUDE.md 상태 문서 규칙 섹션 존재 | test -f .harness/STATE.md && test -f .harness/CONTEXT_INDEX.md && grep -q '상태 문서 규칙' CLAUDE.md | - | cc:완료 | - |

---

## Week 2 — 템플릿 dogfooding (루틴 관리 SaaS로 실전 테스트, 커밋 제외)

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 2.1 | 테스트 프로젝트 골격 생성 | ../routine-saas/에 CLAUDE.md·Plans.md·harness.toml·agents/·docs/templates/·.github/ 복사됨 | - | - | cc:완료 | - |
| 2.2 | 기획 파이프라인 테스트 (grill-me 인터뷰) | ../routine-saas/docs/PRD.md v0.1 존재, Decisions 섹션 기록됨 | - | 2.1 | cc:완료 | - |
| 2.3 | 보완 문서 테스트 (UserFlow·Architecture 골격 적용) | ../routine-saas/docs/UserFlow.md·Architecture.md 존재 | - | 2.2 | cc:완료 | - |
| 2.4 | 계획 파이프라인 테스트 (task-decomposer → Plans.md) | ../routine-saas/Plans.md에 세분화 기준 통과 Task 표 존재 | - | 2.3 | cc:완료 | - |
| 2.5 | 템플릿 결함 기록 | 테스트 중 발견한 템플릿 문제를 .harness/LESSONS.md에 기록, 수정 필요 항목은 Week 3 후보로 정리 | - | 2.4 | cc:완료 | - |
| 2.6 | DESIGN.md 기획 산출물 추가 | docs/templates/DESIGN.md 골격 존재, CLAUDE.md 기획 규칙에 DESIGN 단계 반영, routine-saas에 실제 작성 적용 | test -f docs/templates/DESIGN.md | 2.5 | cc:완료 | - |
| 2.7 | GitHub 연동 E2E 검증 | harness-gh-test repo에서 GitHub 연동 시나리오를 검증하고 발견한 빈틈을 문서화 | grep -q 'GitHub 플로우' CLAUDE.md | 2.5 | cc:완료 | - |

---

## Week 3 — 감사 빈틈 개선 (기준 문서: docs/specs/2026-07-04-template-audit.md)

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 3.1 | GitHub branch protection 호환 (H1) | protection 활성 테스트 repo에서 자동 flip 실증, 선택한 방식(bypass/PR)의 근거를 워크플로 주석에 기록 | grep -qi 'branch protection' docs/github-integration.md | - | cc:완료 | - |
| 3.2 | clean 골격 세트 분리 (H5) | templates/skeleton/에 Plans.md·.harness/ 7종 초기 상태 존재, dogfood 이력 미포함 | test -f templates/skeleton/Plans.md && test -f templates/skeleton/.harness/STATE.md | - | cc:완료 | - |
| 3.3 | init.sh 초기화 스크립트 (H5) | init.sh가 ci.yml·plans-guard.yml·.harness/ 골격 포함 복사, README 수동 cp 절차를 스크립트 안내로 교체 | test -x init.sh && grep -q 'plans-guard.yml' init.sh && grep -q 'ci.yml' init.sh | 3.2 | cc:완료 | - |
| 3.4 | plans-guard 상태 변경 보호 검토 기록 (H2) | Task 상태 변경 보호를 CI가 아닌 세션 에이전트 책임으로 둘지 검토하고 결정을 문서화 | - | 3.6 | cc:완료 | - |
| 3.5 | Depends 검증 경로 정리 (H3) | Depends 존재 여부와 WIP 선행 완료 검증 경로가 validate_tasks.py 기준으로 정리됨 | python3 scripts/validate_tasks.py | 3.6 | cc:완료 | - |
| 3.6 | Plans.md 헤더 검증 선행 파싱 (M1·M7) | 헤더 7컬럼 불일치 시 명시 FAIL(조용한 skip 제거), plans-guard에 적용 | python3 scripts/sync_plans.py --check | - | cc:완료 | - |
| 3.7 | 완료 전환 서술 통일 (M3) | README·BLUEPRINT의 Task 상태 전환 서술을 CLAUDE.md 기준과 일치시킴 | grep -q 'GitHub Actions는 Task 상태를 바꾸지 않는다' README.md && grep -q 'Actions는 Task 상태를 쓰지 않고' BLUEPRINT.md | 3.1 | cc:완료 | - |
| 3.8 | harness.toml 죽은 설정 정리 (M4) | 미사용 키 제거, 미파싱 섹션 역할 주석 재정의(실행 SSOT는 CLAUDE.md) | ! grep -q 'max_iterations' harness.toml | - | cc:완료 | - |
| 3.9 | Plans.md anti-pattern 예시 교정 (M2) | 무력화 패턴(echo skip) 행 교정, repo 밖 경로 acceptance `-` 처리, 주석에 금지 규약 추가 | ! grep -qE 'echo sk[i]p' Plans.md | - | cc:완료 | - |
| 3.10 | agents 문서 수행 주체 명시 (M5) | BLUEPRINT·README에 "절차 문서, 수행 주체=세션 Claude" 명시, .claude/agents/ 이전 여부 결정 기록 | grep -q '수행 주체' BLUEPRINT.md | - | cc:완료 | - |
| 3.11 | ci.yml 이름 고정 요약 잡 (M6) | ci-ok 잡 신설(스택 잡 needs 집약), required check 등록 안내 주석 | grep -q 'ci-ok' .github/workflows/ci.yml | - | cc:완료 | - |
| 3.12 | 플러그인 SHA 기록 절차 (M8) | README 버전 표에 검증 커밋 SHA 컬럼 추가, 업데이트 전 확인 절차 단락 | grep -q 'SHA' README.md | - | cc:완료 | - |

---

## Week 4 — 백로그 정리 (기준 문서: docs/specs/2026-07-04-template-audit.md L1~L5)

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 4.1 | 세분화 기준 표현 정확도 개선 (L1) | agents/task-decomposer.md가 정상 연결어와 여러 관심사 열거 표현을 구분하는 기준을 설명 | grep -q '여러 관심사' agents/task-decomposer.md | - | cc:완료 | - |
| 4.2 | test-agent pretest 오탐 스택 감지 수정 (L2) | "pretest" 스크립트만 있는 package.json을 npm test 스택으로 오판하지 않음 | grep -q '"test":' agents/test-agent.md | - | cc:완료 | - |
| 4.3 | CONTEXT_INDEX.md 미존재 파일 인덱스 정리 (L3) | 이 저장소에 없는 docs/PRD.md·UserFlow.md·Architecture.md 인덱스 항목 제거 | ! grep -q 'docs/PRD.md' .harness/CONTEXT_INDEX.md | - | cc:완료 | - |
| 4.4 | rm 위험 패턴 매칭 범위 확대 (L4) | harness.toml ask 목록이 rm -fr·rm -R 조합도 포착 | [ $(grep -c 'rm -' harness.toml) -gt 1 ] | - | cc:완료 | - |
| 4.5 | grill-me 산출 경로 인자 지원 (L5) | SKILL.md에 대상 디렉토리 인자 규약 명시, 기본값은 현재 프로젝트 docs/ | grep -q '산출 경로' .claude/skills/grill-me/SKILL.md | - | cc:TODO | - |
| 4.6 | grill-me 비대화형 실행 호환 모드 (L5) | 무응답·headless 환경에서 질문마다 권장값으로 자동 확정 후 진행하는 대안 경로 명시 | grep -q 'headless' .claude/skills/grill-me/SKILL.md | - | cc:TODO | - |

---

## Week 4 — Codex 호환 환경 구성

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 4.7 | Codex 호환 진입점 추가 | AGENTS.md가 Codex 진입점으로 존재하고 init.sh가 새 프로젝트에 복사하며 README·BLUEPRINT에 Codex 동작 경로가 명시됨 | test -f AGENTS.md && grep -q 'AGENTS.md' init.sh && grep -q 'Recommended Codex Workflow' README.md | - | cc:완료 | - |
| 4.8 | Codex harness skills 추가 | .agents/skills 아래 harness 흐름 6종 SKILL.md가 존재하고 init.sh가 새 프로젝트에 복사함 | test -f .agents/skills/grill-me/SKILL.md && test -f .agents/skills/harness-plan/SKILL.md && test -f .agents/skills/harness-work/SKILL.md && test -f .agents/skills/harness-review/SKILL.md && test -f .agents/skills/harness-progress/SKILL.md && test -f .agents/skills/harness-sync/SKILL.md && grep -q '.agents/skills' init.sh | 4.7 | cc:완료 | - |
| 4.9 | Git workflow helper command/skill 추가 | Claude custom command와 Codex skill로 branch-checkout·git-push·pr-create 절차가 제공되고 init.sh가 복사함 | test $(find .claude/commands -name '*.md' \| wc -l) -ge 3 && test -f .agents/skills/branch-checkout/SKILL.md && test -f .agents/skills/git-push/SKILL.md && test -f .agents/skills/pr-create/SKILL.md && grep -q '.claude/commands' init.sh | 4.8 | cc:완료 | - |
| 4.10 | Claude/Codex 공용 Quality Gate 문서화 | docs/specs/2026-07-08-codex-claude-quality-gates.md와 agents/quality-gates.md가 존재하고 Codex skill, README, BLUEPRINT, AGENTS, init skeleton이 quality gate 기준을 참조함 | test -f docs/specs/2026-07-08-codex-claude-quality-gates.md && test -f agents/quality-gates.md && grep -q 'YAGNI' agents/quality-gates.md && grep -q 'caveman' README.md && grep -q 'agents/quality-gates.md' .agents/skills/harness-work/SKILL.md && grep -q 'agents/quality-gates.md' .agents/skills/harness-review/SKILL.md | 4.8 | cc:완료 | - |
| 4.11 | rescue-from-main workflow helper 추가 | Claude custom command와 Codex skill로 rescue-from-main 절차가 제공되고 AGENTS·README·BLUEPRINT·init 복사 경로에 등록됨 | test -f .agents/skills/rescue-from-main/SKILL.md && test -f .claude/commands/rescue-from-main.md && grep -q 'rescue-from-main' AGENTS.md && grep -q 'rescue-from-main' README.md && grep -q 'rescue-from-main' BLUEPRINT.md | 4.9, 4.10 | cc:완료 | - |
| 4.12 | Task별 .harness 맥락 디렉토리 도입 | .harness/tasks/<task-key>/ 구조와 루트 템플릿 역할이 문서·skeleton·최근 이관 예시로 정리됨 | test -d .harness/tasks/4.11-rescue-from-main && test -d .harness/tasks/readme-user-friendly && test -f .harness/tasks/readme-user-friendly/tasks.index.snapshot.json && test -f templates/skeleton/.harness/tasks/.gitkeep && grep -q '템플릿' .harness/STATE.md && grep -q '.harness/tasks' CLAUDE.md && grep -q '.harness/tasks' AGENTS.md && grep -q '.harness/tasks' .agents/skills/harness-work/SKILL.md && python3 scripts/validate_tasks.py && python3 scripts/sync_plans.py --check | 4.11 | cc:완료 | - |

---

<!--
Task 상태의 단일 출처는 tasks/index.json이다.
Plans.md는 사람이 필요할 때 python3 scripts/sync_plans.py로 갱신하는
읽기용 snapshot이며 stale일 수 있다. 상태 판단과 CI 검증은 항상
tasks/index.json을 기준으로 한다.

JSON status 값:
  todo    — 미시작 (Plans.md 표시: cc:TODO)
  wip     — 진행 중 (Plans.md 표시: cc:WIP)
  done    — 완료 (Plans.md 표시: cc:완료)
  blocked — 차단됨 (Plans.md 표시: cc:BLOCKED, blocked_reason 필수)

GH 컬럼:
  -         — GitHub 미연동 또는 이슈 미생성
  #N        — 연결된 GitHub Issue 번호 (harness-plan이 자동 기입)

Acceptance 컬럼:
  -         — 기계 검증 없음 (skip). "|| echo skip"처럼 항상 성공하는
              패턴은 oracle을 무력화하므로 금지 — 검증 안 할 거면 "-"로 명시.
  명령어     — 세션 에이전트가 완료 전 실행, 실패하면 done 전환 금지.
              CI checkout 범위 밖 경로(예: ../다른-repo/)는 실행 불가 — 금지.
              Given=repo checkout/Depends 산출물, When=명령 실행, Then=exit 0
              또는 출력·파일·응답 검증이 되도록 쓴다.
  예시: pytest tests/test_auth.py -k login
  예시: curl -sf http://localhost/health | grep '"status":"ok"'
  패턴별 예시:
    파일 존재: test -f src/main.py
    명령 성공: npm run build 2>&1 | grep -v error
    HTTP 응답: curl -sf http://localhost:3000/health | grep ok
    테스트 통과: pytest tests/ -x -q
    출력 포함: go test ./... | grep -v SKIP
  escaped pipe(예: grep 'a\|b')는 Acceptance 컬럼에서만 사용 — DoD 등 다른
  컬럼에 쓰면 파서가 열 개수를 오인식한다.
  * GitHub CI 스택 설치(npm ci 등)는 .github/workflows/ci.yml에서 설정

DoD (Definition of Done) 작성 원칙:
  - 검증 가능한 파일·명령·출력으로 기술
  - "존재한다", "성공한다", "에러 0"처럼 객관적 기준
  - "잘 작성된다", "좋다"처럼 주관적 기준 금지
  - INVEST 기준: 독립 검증 가능, 관찰 가능한 가치, 1 PR 이내, 테스트 가능
-->
