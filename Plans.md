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
| 0.4 | Plugin 설정 | ponytail·caveman·VFF 설치 확인, agent MEMORY.md 3개 존재 | grep -q 'caveman\|ponytail' ~/.claude/settings.json 2>/dev/null \|\| echo skip | 0.3 | cc:완료 | - |

---

## Week 1 — 템플릿 개선

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 1.0 | Plans.md 템플릿 개선 | bootstrap Task에 Acceptance 예시 있음, 현실적 샘플 Task 포함 | grep -qE 'test -f\|npm test\|pytest\|go test\|curl' Plans.md | - | cc:완료 | - |
| 1.1 | test agent 추가 | agents/test-agent.md 존재, harness.toml [test] 섹션, BLUEPRINT.md 업데이트 | test -f agents/test-agent.md | - | cc:완료 | - |
| 1.2 | 기획 파이프라인 추가 | grill-me 스킬 + docs/templates/ 골격 3종, CLAUDE.md 기획 규칙 | test -f .claude/skills/grill-me/SKILL.md && test -f docs/templates/PRD.md | - | cc:완료 | - |
| 1.3 | task-decomposer + 세분화 게이트 추가 | agents/task-decomposer.md 존재, harness.toml [plan] 섹션, plans-guard.yml granularity-check 잡, CLAUDE.md 구현 규칙 | test -f agents/task-decomposer.md && grep -q 'granularity-check' .github/workflows/plans-guard.yml | 1.1 | cc:완료 | - |

---

## Week 2 — [주제]

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 2.1 | [내용] | [완료 기준] | - | - | cc:TODO | - |

---

<!-- 
Task Status 마커:
  cc:TODO   — 미시작
  cc:WIP    — 진행 중 (harness가 자동 설정)
  cc:완료   — 완료 (harness가 자동 설정)

GH 컬럼:
  -         — GitHub 미연동 또는 이슈 미생성
  #N        — 연결된 GitHub Issue 번호 (harness-plan이 자동 기입)

Acceptance 컬럼:
  -         — 기계 검증 없음 (skip)
  명령어     — PR 오픈 시 plans-guard CI가 실행, 실패하면 PR 차단
  예시: pytest tests/test_auth.py -k login
  예시: curl -sf http://localhost/health | grep '"status":"ok"'
  패턴별 예시:
    파일 존재: test -f src/main.py
    명령 성공: npm run build 2>&1 | grep -v error
    HTTP 응답: curl -sf http://localhost:3000/health | grep ok
    테스트 통과: pytest tests/ -x -q
    출력 포함: go test ./... | grep -v SKIP
  * 스택 설치(npm ci 등)는 .github/workflows/plans-guard.yml 상단 주석 해제

DoD (Definition of Done) 작성 원칙:
  - 검증 가능한 파일·명령·출력으로 기술
  - "존재한다", "성공한다", "에러 0"처럼 객관적 기준
  - "잘 작성된다", "좋다"처럼 주관적 기준 금지
-->
