# Plans.md — [PROJECT_NAME]

작성일: YYYY-MM-DD
기준 문서: docs/PRD.md

---

## Week 0 — 부트스트랩

| Task | 내용 | DoD | Acceptance | Depends | Status | GH |
|------|------|-----|------------|---------|--------|----|
| 0.1 | PRD 작성 (`/grill-me` 인터뷰) | docs/PRD.md v0.1 존재, Open Questions 정리됨 | test -f docs/PRD.md | - | cc:TODO | - |
| 0.2 | 기획 보완 문서 | UserFlow.md·Architecture.md 작성 (docs/templates/ 골격 사용) | test -f docs/UserFlow.md && test -f docs/Architecture.md | 0.1 | cc:TODO | - |
| 0.3 | Harness 초기화 | harness doctor 전체 통과, CLAUDE.md·Plans.md 존재 | test -f CLAUDE.md && test -f Plans.md && test -f harness.toml | - | cc:TODO | - |
| 0.4 | Plugin 설정 | ponytail·caveman 등 필요한 플러그인 설치 확인 | test -f ~/.claude/settings.json | 0.3 | cc:TODO | - |

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
