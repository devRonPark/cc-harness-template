---
name: pr-create
description: 현재 작업 브랜치에서 GitHub PR을 작성한다. PR 생성, draft PR 작성, Task 기반 PR 본문 작성 요청 시 사용.
---

# pr-create

현재 작업 브랜치에서 GitHub PR을 작성한다.

## 절차

1. `git status --short`와 `git branch --show-current`를 확인한다.
2. 현재 브랜치가 `main`/`master`면 PR을 만들지 않는다.
3. 커밋되지 않은 변경분이 있으면 커밋이 필요하다고 보고하고 중단한다.
4. 대상 Task를 `tasks/index.json`에서 확인한다.
5. PR 본문에 변경 요약, 검증 결과, DoD/Acceptance evidence, 남은 위험을 포함한다.
6. Task의 `gh` 값이 `#N`이면 `Closes #N`을 포함한다.
7. 기본은 `gh pr create --draft`다. 사용자가 ready PR을 명시하면 draft를 생략할 수 있다.
8. 생성 후 PR URL과 남은 merge gate를 보고한다.

## 제한

- Acceptance evidence가 없거나 리뷰가 `REQUEST_CHANGES`면 PR 생성 전 중단한다.
- GitHub 모드에서는 PR 안에서 Task를 `done`으로 바꾸지 않는다.
