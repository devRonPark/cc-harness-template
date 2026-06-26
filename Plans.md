# Plans.md — [PROJECT_NAME]

작성일: YYYY-MM-DD
기준 문서: docs/your-prd.md

---

## 완료된 작업

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 0.1 | PRD 작성 | docs/your-prd.md v0.1 존재 | - | - | cc:완료 | - |
| 0.2 | Harness 초기화 | harness doctor 전체 통과, CLAUDE.md·Plans.md 존재 | - | - | cc:완료 | - |
| 0.3 | Plugin 설정 | ponytail·caveman·VFF 설치 확인, agent MEMORY.md 3개 존재 | - | 0.2 | cc:완료 | - |

---

## Week 1 — [주제]

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 1.0 | [내용] | [완료 기준] | - | - | cc:TODO | - |
| 1.1 | [내용] | [완료 기준] | - | 1.0 | cc:TODO | - |

---

## Week 2 — [주제]

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 2.1 | [내용] | [완료 기준] | - | 1.1 | cc:TODO | - |

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
  * 스택 설치(npm ci 등)는 .github/workflows/plans-guard.yml 상단 주석 해제

DoD (Definition of Done) 작성 원칙:
  - 검증 가능한 파일·명령·출력으로 기술
  - "존재한다", "성공한다", "에러 0"처럼 객관적 기준
  - "잘 작성된다", "좋다"처럼 주관적 기준 금지
-->
