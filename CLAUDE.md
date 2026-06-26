# [PROJECT_NAME] — CLAUDE.md

## 프로젝트 개요

**[프로젝트 한 줄 설명]**
[추가 컨텍스트 — 공모전, 고객사, 내부 툴 등]

## 기술 스택

- **런타임**: [Node.js / Python / Go / ...]
- **주요 프레임워크**: [...]
- **배포**: [...]
- **저장소**: [...]

## 디렉토리 구조

```
[project-name]/
├── src/
├── docs/
├── Plans.md
├── harness.toml
└── package.json (또는 pyproject.toml 등)
```

## 언어 규칙

- **모든 응답은 한국어로 작성한다.** 코드·명령어·고유명사는 그대로 유지.

## 코딩 규칙

- [프로젝트별 코딩 컨벤션 기입]
- [예: 함수 네이밍 규칙, import 순서, 에러 처리 방식 등]

## GitHub 플로우

> `harness.toml`의 `[github] enabled = true` 시 적용. 미사용이면 이 섹션 삭제.

- **브랜치 명명**: `task/{task-id}-{짧은-설명}` (예: `task/1.1-auth-login`)
- **Planning**: `/harness-plan` → Week → Milestone, Task → Issue 자동 생성
- **Implementation**: Task당 브랜치 생성 → 구현 → `Closes #{issue}` PR 오픈
- **Merge 조건**: CI 통과 (`ci` + `plans-guard`) + PR 승인 후 main 머지
- **CI 설정**: `.github/workflows/ci.yml` 기술 스택 블록 주석 해제 후 사용

## 개발 일정

- Week 1: [...]
- Week 2: [...]
- Week N: [...]
