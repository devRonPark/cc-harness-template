---
description: Push the current branch safely after checking status, branch, and upstream.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git remote:*), Bash(git push:*), Read
---

# /git-push

현재 브랜치를 원격에 push한다. push 전에 브랜치, 변경분, upstream을 확인하고
강제 push는 하지 않는다.

## 절차

1. `git status --short`와 `git branch --show-current`를 확인한다.
2. 현재 브랜치가 `main`/`master`면 push하지 말고 사용자에게 확인을 요청한다.
3. 커밋되지 않은 변경분이 있으면 push 대상이 아님을 알리고 중단한다.
4. upstream이 있으면 `git push`를 실행한다.
5. upstream이 없으면 `git push -u origin {current-branch}`를 실행한다.
6. push 결과와 다음 단계(PR 작성 여부)를 보고한다.

## 주의

- `--force`, `--force-with-lease`는 사용하지 않는다.
- 인증 실패나 remote 없음은 원문 에러를 보고하고 멈춘다.
- 인자: `$ARGUMENTS`
