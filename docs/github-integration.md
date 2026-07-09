# GitHub Integration

GitHub 연동은 Issue/PR 추적과 CI 검증만 맡는다. `tasks/index.json`의 `todo`/`wip`/`done` 상태는 세션 에이전트가 직접 바꾸며, GitHub Actions는 Task 상태를 변경하지 않는다.

## Enable

사전 조건:

```bash
gh auth login
git remote -v
```

`harness.toml`:

```toml
[github]
enabled = true
milestone_per_week = true
issue_per_task = true
require_ci = true
```

```bash
harness sync
```

## CI

`.github/workflows/ci.yml`에서 `placeholder`를 실제 `check`/`test` job으로 교체하고 `ci-ok`의 `needs`를 갱신한다.

Branch protection required check는 이름이 고정된 `ci-ok` 하나를 기술 스택 CI 대표로 등록한다.

## Branch Protection

GitHub Settings -> Branches -> main:

| 설정 | 값 |
|---|---|
| Require status checks | `ci-ok` |
| Require status checks | `plans-guard / tasks/index.json 검증` |
| Require status checks | `plans-guard / Plans.md sync 검증` |
| Require pull request | enabled |
| Dismiss stale reviews | enabled |

Task 상태 관련 check는 required로 두지 않는다. 상태 전환은 Acceptance/test를 본 세션 에이전트 책임이다.

## Planning

`/harness-plan` 또는 `$harness-plan` 후 GitHub 연동 시:

1. `tasks/index.json`의 section -> GitHub Milestone
2. 각 Task -> GitHub Issue
3. 생성된 issue 번호 -> Task `gh` 값 `#N`

수동 생성:

```bash
gh api repos/{owner}/{repo}/milestones -f title="Week 1"
gh issue create --title "[1.1] 기능 구현" --body "DoD: ..." --milestone "Week 1"
```

## Implementation

1. `task/{task-id}-{short-slug}` 브랜치 생성
2. Task를 `wip`로 바꾸고 `python3 scripts/sync_plans.py` 실행
3. 구현, Acceptance, 관련 테스트 통과
4. Task를 `done`으로 바꾸고 `python3 scripts/sync_plans.py` 실행
5. `gh pr create --draft` 실행. 연결 issue가 있으면 `Closes #N` 포함
6. `ci-ok`, `plans-guard`, review 승인 후 merge

수동 PR:

```bash
git switch -c task/1.1-auth-login
git push -u origin task/1.1-auth-login
gh pr create --draft --title "[1.1] auth login 구현" --body "Closes #5"
```

## plans-guard

`plans-guard.yml`은 PR에서 쓰기 없는 검증만 수행한다.

- `python3 scripts/validate_tasks.py`
- `python3 scripts/sync_plans.py --check`

Acceptance 명령 실행, branch와 WIP 상태 일치 확인, Task 상태 변경 범위 판단은 `CLAUDE.md`, `agents/test-agent.md`, `agents/quality-gates.md`를 따르는 세션 에이전트 책임이다.

## Useful Commands

```bash
gh issue list
gh pr list
gh run list --workflow=ci.yml
gh run watch
```
