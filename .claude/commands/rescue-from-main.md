---
description: Move accidental main/master work to a content-named branch, then commit, push, and open a draft PR.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git remote:*), Bash(git diff:*), Bash(git log:*), Bash(git ls-remote:*), Bash(git switch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh auth status:*), Bash(gh pr create:*), Bash(gh pr view:*), Read
---

# /rescue-from-main

`main`/`master`에서 실수로 작업한 변경사항을 안전하게 작업 브랜치로 옮긴 뒤
`commit -> push -> draft PR`까지 진행한다. 자동 reset이나 강제 push는 하지 않는다.

## 절차

1. `git status --short --branch`, `git branch --show-current`, `git branch -vv`,
   `git remote -v`로 현재 브랜치, upstream, remote, 변경분을 확인한다.
2. `gh auth status` 또는 `gh pr view`로 GitHub CLI 사용 가능 여부를 확인한다.
3. `git diff --stat`, `git diff --name-status`를 읽고, staged 변경이 있으면
   `git diff --cached --stat`, `git diff --cached --name-status`도 읽는다.
4. 변경 파일과 diff 요약, 필요 시 최근 commit 제목을 근거로 브랜치명을 정한다.
   Task ID가 있으면 `task/{task-id}-{change-slug}`, 없으면 `work/{change-slug}`를
   사용한다. slug는 2-5개 단어 kebab-case이며 `fix`, `update`, `changes`, `misc`,
   `wip` 단독 이름은 금지한다.
5. `git branch --list {branch}`와 `git ls-remote --heads origin {branch}`로 충돌을
   확인하고, 충돌하면 `-{n}` suffix를 붙인다.
6. 현재 브랜치가 `main`/`master`이고 uncommitted 변경이 있으면
   `git switch -c {branch}`를 실행해 변경사항을 그대로 보존한다.
7. 현재 브랜치가 `main`/`master`이고 upstream보다 앞선 local commit이 있으면
   자동 reset하지 않고 중단한다. 새 브랜치 보존과 main 복구는 별도 승인 후 처리한다.
8. 이미 작업 브랜치면 브랜치명이 변경 내용과 맞는지 확인하고 그대로 진행한다.
9. 변경분을 `git add`로 stage한다. 범위 밖 파일이 섞여 있으면 제외하거나 중단한다.
10. Task가 있으면 `task {task-id}: {summary}`, 없으면 `{summary}` 형식으로
    `git commit`을 실행한다.
11. `git push -u origin {branch}`로 원격에 올린다.
12. `gh pr create --draft`로 draft PR을 만든다. PR 본문에는 변경 요약, 검증 결과,
    Acceptance evidence, residual risk, Task `gh`가 `#N`이면 `Closes #N`을 포함한다.

## 주의

- `git reset --hard`, `git checkout --`, 강제 push는 실행하지 않는다.
- 브랜치명은 반드시 변경사항 내용을 검사해 만든다.
- 인증/권한/remote 오류는 원문을 요약하고 멈춘다.
- 인자: `$ARGUMENTS`
