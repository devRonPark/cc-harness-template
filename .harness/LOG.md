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
