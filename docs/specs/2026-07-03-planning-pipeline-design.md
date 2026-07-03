# 기획 단계 산출물 파이프라인 — 설계

작성일: 2026-07-03
상태: 승인됨

## 문제

템플릿 파이프라인이 Plans.md Task 0.1 "PRD 작성"에서 시작하지만,
PRD를 **어떻게** 만드는지에 대한 규약·도구·골격이 없다.
기획 단계 산출물(PRD, User Flow, Architecture)이 공백.

## 목표

- 아이디어 → PRD → 보완 문서 → Plans.md 로 이어지는 기획 파이프라인을 템플릿에 내장
- 스킬 의존성 self-contained (유저 글로벌 스킬 불필요)

## Non-goals

- planner agent — grill-me로 부족할 때 추가 (합의됨)
- ADR.md 별도 파일 — PRD Decisions 섹션으로 시작, 개발 중 필요 시 `docs/adr/` 분리
- UserFlow/Architecture 전용 스킬 — 템플릿 골격 + CLAUDE.md 규약으로 충분

## 흐름

```
아이디어 → /grill-me (인터뷰) → docs/PRD.md 초안
        → UserFlow.md · Architecture.md 보완
        → /harness-plan 이 PRD 기반 Plans.md 생성 → 기존 harness 흐름
```

## 변경 파일

| 파일 | 종류 | 내용 |
|------|------|------|
| `.claude/skills/grill-me/SKILL.md` | 신규 | 프로젝트 스코프 인터뷰 스킬. 질문 1개씩, 각 질문에 권장답 제시, 코드베이스로 답 가능하면 탐색으로 대체. 종료 시 `docs/PRD.md` 작성까지 스킬 책임 |
| `docs/templates/PRD.md` | 신규 | Goals / Non-goals / 요구사항 / 성공기준 / Decisions / Open Questions 골격 |
| `docs/templates/UserFlow.md` | 신규 | mermaid flowchart 골격 (화면·상태 전이) |
| `docs/templates/Architecture.md` | 신규 | 스택 / 컴포넌트 경계 / 데이터 흐름 골격 |
| `CLAUDE.md` | 수정 | 기획 규약 섹션 추가: 착수 시 `/grill-me` → PRD → 보완 → `/harness-plan`. 플러그인 자동 실행 아님 명시 (test 규칙과 동일 패턴) |
| `Plans.md` | 수정 | Task 0.1을 `/grill-me` 기반으로 갱신, Acceptance `test -f docs/PRD.md` |
| `README.md` / `BLUEPRINT.md` | 수정 | 파이프라인 다이어그램·문서 표에 기획 단계 반영 |

## 엣지 케이스

- **인터뷰 중단**: PRD에 Open Questions 남긴 채 저장. 재실행 시 기존 PRD 읽고 이어서.
- **기존 PRD 보유 프로젝트**: 스킬이 기존 문서 읽고 gap만 인터뷰.
- **grill-me 이름 충돌**: 유저 글로벌 `grill-me`와 동명. 프로젝트 스코프가 우선되며 내용상 동일 계열이라 실질 충돌 없음.

## 검증

- `test -f .claude/skills/grill-me/SKILL.md`
- `test -f docs/templates/PRD.md && test -f docs/templates/UserFlow.md && test -f docs/templates/Architecture.md`
- `grep -q 'grill-me' CLAUDE.md Plans.md README.md`
