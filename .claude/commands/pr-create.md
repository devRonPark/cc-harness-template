---
description: Create a GitHub pull request from the current task branch with task and acceptance context.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git log:*), Bash(gh pr create:*), Bash(gh pr view:*), Read
---

# /pr-create

현재 작업 브랜치에서 GitHub PR을 작성한다. PR 본문에는 Task, DoD, Acceptance evidence,
리뷰 상태, 이슈 연결 정보를 포함한다.

## 절차

1. `git status --short`와 `git branch --show-current`를 확인한다.
2. 현재 브랜치가 `main`/`master`면 PR을 만들지 않는다.
3. 커밋되지 않은 변경분이 있으면 PR 생성 전에 커밋 필요 여부를 보고하고 중단한다.
4. 대상 Task를 `tasks/index.json`에서 확인하고, `gh`가 `#N`이면 PR 본문에 `Closes #N`을 넣는다.
5. Acceptance와 관련 테스트 실행 증거를 PR 본문에 요약한다.
6. `gh pr create --draft`를 기본으로 사용한다. 사용자가 ready PR을 명시하면 draft를 생략할 수 있다.
7. 생성 후 PR URL과 남은 merge gate를 보고한다.

## 주의

- `REQUEST_CHANGES` 상태이거나 Acceptance evidence가 없으면 PR 생성 전 중단한다.
- GitHub 모드에서는 PR 안에서 Task를 `done`으로 바꾸지 않는다.
- 인자: `$ARGUMENTS`
