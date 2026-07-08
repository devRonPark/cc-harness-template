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
| 1.3 | task-decomposer + 세분화 게이트 추가 | agents/task-decomposer.md 존재, harness.toml [plan] 섹션, plans-guard.yml granularity-check 잡, CLAUDE.md 구현 규칙 | test -f agents/task-decomposer.md && grep -q 'granularity-check' .github/workflows/plans-guard.yml | 1.1 | cc:완료 | - |
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
| 2.7 | GitHub 연동 E2E 검증 + plans-complete 워크플로 | harness-gh-test repo에서 plans-guard 3잡 시나리오 4종 검증, 빈틈 7건 도출, plans-complete.yml 신설 검증, CLAUDE.md GitHub 플로우 명문화 | test -f .github/workflows/plans-complete.yml && grep -q 'plans-complete' CLAUDE.md | 2.5 | cc:완료 | - |

---

## Week 3 — 감사 빈틈 개선 (기준 문서: docs/specs/2026-07-04-template-audit.md)

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 3.1 | plans-complete branch protection 호환 (H1) | protection 활성 테스트 repo에서 자동 flip 실증, 선택한 방식(bypass/PR)의 근거를 워크플로 주석에 기록 | grep -qi 'protection' .github/workflows/plans-complete.yml | - | cc:완료 | - |
| 3.2 | clean 골격 세트 분리 (H5) | templates/skeleton/에 Plans.md·.harness/ 7종 초기 상태 존재, dogfood 이력 미포함 | test -f templates/skeleton/Plans.md && test -f templates/skeleton/.harness/STATE.md | - | cc:완료 | - |
| 3.3 | init.sh 초기화 스크립트 (H5) | init.sh가 plans-complete.yml·ci.yml·.harness/ 골격 포함 복사, README 수동 cp 절차를 스크립트 안내로 교체 | test -x init.sh && grep -q 'plans-complete.yml' init.sh | 3.2 | cc:완료 | - |
| 3.4 | plans-guard diff 보호 잡 (H2) | 비-task 브랜치의 Status 변경 PR 차단, task 브랜치의 타 행 Status 변경 차단 — 시나리오 2종 테스트 repo 검증 | grep -q 'plans-diff-check' .github/workflows/plans-guard.yml | 3.6 | cc:완료 | - |
| 3.5 | plans-guard depends-check 잡 (H3) | WIP Task의 Depends 대상이 cc:완료 아니면 FAIL — 시나리오 검증 | grep -q 'depends-check' .github/workflows/plans-guard.yml | 3.6 | cc:완료 | - |
| 3.6 | Plans.md 헤더 검증 선행 파싱 (M1·M7) | 헤더 7컬럼 불일치 시 명시 FAIL(조용한 skip 제거), plans-guard·plans-complete에 공통 적용 | grep -q 'header-check' .github/workflows/plans-guard.yml | - | cc:완료 | - |
| 3.7 | 완료 전환 서술 통일 (M3) | README·BLUEPRINT의 세션 직접 flip 서술을 CLAUDE.md 기준(plans-complete 자동 전환)으로 교체 | grep -q 'plans-complete' README.md && grep -q 'plans-complete' BLUEPRINT.md | 3.1 | cc:완료 | - |
| 3.8 | harness.toml 죽은 설정 정리 (M4) | 미사용 키 제거, 미파싱 섹션 역할 주석 재정의(실행 SSOT는 CLAUDE.md) | ! grep -q 'max_iterations' harness.toml | - | cc:완료 | - |
| 3.9 | Plans.md anti-pattern 예시 교정 (M2) | 무력화 패턴(echo skip) 행 교정, repo 밖 경로 acceptance `-` 처리, 주석에 금지 규약 추가 | ! grep -qE 'echo sk[i]p' Plans.md | - | cc:완료 | - |
| 3.10 | agents 문서 수행 주체 명시 (M5) | BLUEPRINT·README에 "절차 문서, 수행 주체=세션 Claude" 명시, .claude/agents/ 이전 여부 결정 기록 | grep -q '수행 주체' BLUEPRINT.md | - | cc:완료 | - |
| 3.11 | ci.yml 이름 고정 요약 잡 (M6) | ci-ok 잡 신설(스택 잡 needs 집약), required check 등록 안내 주석 | grep -q 'ci-ok' .github/workflows/ci.yml | - | cc:완료 | - |
| 3.12 | 플러그인 SHA 기록 절차 (M8) | README 버전 표에 검증 커밋 SHA 컬럼 추가, 업데이트 전 확인 절차 단락 | grep -q 'SHA' README.md | - | cc:완료 | - |

---

## Week 4 — 백로그 정리 (기준 문서: docs/specs/2026-07-04-template-audit.md L1~L5)

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 4.1 | granularity 오탐지 정규식 정확도 개선 (L1) | vague_re가 "그리고" 포함 정상 문장은 통과시키고 쉼표 나열·"와"/"과" 열거 표현은 미달로 탐지 | ! grep -q "vague_re='(전체\|모든\| 및 \|그리고)'" .github/workflows/plans-guard.yml | - | cc:TODO | - |
| 4.2 | test-agent pretest 오탐 스택 감지 수정 (L2) | "pretest" 스크립트만 있는 package.json을 npm test 스택으로 오판하지 않음 | grep -q '"test":' agents/test-agent.md | - | cc:TODO | - |
| 4.3 | CONTEXT_INDEX.md 미존재 파일 인덱스 정리 (L3) | 이 저장소에 없는 docs/PRD.md·UserFlow.md·Architecture.md 인덱스 항목 제거 | ! grep -q 'docs/PRD.md' .harness/CONTEXT_INDEX.md | - | cc:TODO | - |
| 4.4 | rm 위험 패턴 매칭 범위 확대 (L4) | harness.toml ask 목록이 rm -fr·rm -R 조합도 포착 | [ $(grep -c 'rm -' harness.toml) -gt 1 ] | - | cc:TODO | - |
| 4.5 | grill-me 산출 경로 인자 지원 (L5) | SKILL.md에 대상 디렉토리 인자 규약 명시, 기본값은 현재 프로젝트 docs/ | grep -q '산출 경로' .claude/skills/grill-me/SKILL.md | - | cc:TODO | - |
| 4.6 | grill-me 비대화형 실행 호환 모드 (L5) | 무응답·headless 환경에서 질문마다 권장값으로 자동 확정 후 진행하는 대안 경로 명시 | grep -q 'headless' .claude/skills/grill-me/SKILL.md | - | cc:TODO | - |

---

<!--
Task 상태의 단일 출처는 tasks/index.json이다.
Plans.md의 Task 표와 Status 컬럼은 직접 편집하지 말고 tasks/index.json을 수정한 뒤
python3 scripts/sync_plans.py를 실행한다. CI에서는 scripts/validate_tasks.py가
tasks/index.json을 검증하고, --check로 Plans.md 동기화 여부를 확인한다.

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
  명령어     — PR 오픈 시 plans-guard CI가 실행, 실패하면 PR 차단.
              CI checkout 범위 밖 경로(예: ../다른-repo/)는 실행 불가 — 금지.
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
  * 스택 설치(npm ci 등)는 .github/workflows/plans-guard.yml 상단 주석 해제

DoD (Definition of Done) 작성 원칙:
  - 검증 가능한 파일·명령·출력으로 기술
  - "존재한다", "성공한다", "에러 0"처럼 객관적 기준
  - "잘 작성된다", "좋다"처럼 주관적 기준 금지
-->
