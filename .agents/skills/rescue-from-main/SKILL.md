---
name: rescue-from-main
description: main/master에서 만든 변경사항을 안전하게 작업 브랜치로 옮긴 뒤 commit, push, draft PR까지 진행한다.
---

# rescue-from-main

`main`/`master`에서 실수로 작업한 변경사항을 내용 기반 작업 브랜치로 옮기고
`commit -> push -> draft PR`까지 이어간다. 자동 reset이나 강제 push는 하지 않는다.

## Preflight

1. `git status --short --branch`로 현재 브랜치와 변경분을 확인한다.
2. `git branch --show-current`, `git branch -vv`, `git remote -v`로 현재 브랜치,
   upstream, remote를 확인한다.
3. `gh auth status` 또는 `gh pr view`로 GitHub CLI 사용 가능 여부를 확인한다.
   인증/권한 오류는 원문을 요약하고 중단한다.
4. `git diff --stat`, `git diff --name-status`를 읽는다. staged 변경이 있으면
   `git diff --cached --stat`, `git diff --cached --name-status`도 읽는다.
5. 변경분이 없고 현재 브랜치에만 push되지 않은 commit도 없으면 중단한다.

## 변경 분석과 브랜치명

1. 변경 파일, diff 요약, staged diff, 필요 시 최근 commit 제목을 근거로 짧은
   `{change-slug}`를 만든다.
2. Task ID가 명확하면 `task/{task-id}-{change-slug}`를 사용한다. Task가 없으면
   `work/{change-slug}`를 사용한다.
3. `{change-slug}`는 diff 내용에서 2-5개 단어를 뽑아 kebab-case로 만든다.
4. `fix`, `update`, `changes`, `misc`, `wip`처럼 내용이 불명확한 단독 slug는 금지한다.
5. `git branch --list {branch}`와 `git ls-remote --heads origin {branch}`로 충돌을
   확인한다. 충돌하면 `-{n}` suffix를 붙인다.

## 브랜치 처리

1. 현재 브랜치가 `main`/`master`이고 uncommitted 변경이 있으면
   `git switch -c {branch}`로 새 브랜치를 만든다. Git은 변경분을 그대로 보존한다.
2. 현재 브랜치가 `main`/`master`이고 upstream보다 앞선 local commit이 있으면
   자동으로 옮기거나 reset하지 않고 중단한다. 새 브랜치에 commit을 보존하는 작업과
   `main` 복구는 사용자에게 별도 승인받은 뒤 진행한다.
3. 이미 작업 브랜치면 브랜치명이 변경 내용과 맞는지 확인한다. 맞으면 그대로 진행하고,
   불명확하면 rename 여부를 사용자에게 확인한다.

## Commit

1. `tasks/index.json`에서 대상 Task가 있으면 DoD/Acceptance를 확인한다.
2. `git add {files}` 또는 `git add -A`로 변경분을 stage한다. 사용자 요청 범위 밖
   파일이 섞여 있으면 제외하거나 중단하고 보고한다.
3. 커밋 메시지는 Task가 있으면 `task {task-id}: {summary}`, 없으면 `{summary}`를
   사용한다.
4. `git commit -m "{message}"`를 실행한다.

## Push와 Draft PR

1. `git push -u origin {branch}`를 실행한다. 강제 push는 사용하지 않는다.
2. Acceptance command와 관련 테스트 결과를 PR 본문에 적는다.
3. `gh pr create --draft`로 draft PR을 만든다.
4. PR 본문에는 다음 항목을 포함한다.
   - 변경 요약
   - 검증 결과
   - Acceptance evidence
   - residual risk
   - Task `gh` 값이 `#N`이면 `Closes #N`

## 제한

- `git reset --hard`, `git checkout --`, `git push --force`, `git push --force-with-lease`는
  실행하지 않는다.
- `main`/`master`에 local commit이 있으면 자동 복구하지 않는다.
- 브랜치명은 반드시 diff 내용을 근거로 만든다. 날짜, 사용자명, `wip` 단독 이름은
  사용하지 않는다.
- PR 생성 전 Acceptance evidence가 없으면 draft PR 본문에 미실행 사유를 명확히
  적거나, 사용자가 요구한 경우 중단한다.
