---
description: Create or switch to a dedicated task branch after checking repository state.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git switch:*), Bash(git fetch:*), Read
---

# /branch-checkout

별도 작업 브랜치를 만들거나 체크아웃한다. 사용자가 지정한 브랜치명이 있으면 사용하고,
없으면 대상 Task ID와 제목을 바탕으로 `task/{task-id}-{short-slug}` 형식을 제안한다.

## 절차

1. `git status --short`와 `git branch --show-current`로 현재 상태를 확인한다.
2. 변경분이 있으면 사용자 변경을 덮지 않도록 요약하고, 그대로 브랜치를 전환해도 되는지 확인한다.
3. 필요하면 `git fetch origin`으로 원격 기준을 최신화한다.
4. 기존 브랜치면 `git switch {branch}`를 실행한다.
5. 새 브랜치면 기본 브랜치 기준을 확인한 뒤 `git switch -c {branch}`를 실행한다.
6. 전환 후 현재 브랜치와 남은 변경분을 보고한다.

## 주의

- `git checkout --`, `git reset --hard`, 강제 push는 실행하지 않는다.
- Task 브랜치는 `CLAUDE.md`의 GitHub 플로우에 맞춰 `task/{task-id}-{짧은-설명}`을 선호한다.
- 인자: `$ARGUMENTS`
