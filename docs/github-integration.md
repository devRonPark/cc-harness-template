# GitHub 통합 가이드

harness 템플릿의 GitHub 연동 기능 설정 및 사용법.

---

## 사전 조건

- `gh` CLI 설치 및 로그인: `gh auth login`
- GitHub에 원격 repo 존재 (`git remote -v`로 확인)

---

## Step 1. 활성화

`harness.toml`에서 `[github]` 섹션 수정:

```toml
[github]
enabled = true
# remote = "origin"           # 기본값, 변경 불필요
# default_branch = "main"     # 기본값
milestone_per_week = true     # Week → Milestone 자동 생성
issue_per_task = true         # Task → Issue 자동 생성
require_ci = true             # CI 통과 없이 main 머지 금지
```

이후:
```bash
harness sync
```

---

## Step 2. Branch Protection 설정

GitHub 웹 → **Settings → Branches → Add branch ruleset → main**:

| 항목 | 값 |
|------|----|
| Require status checks | `ci-ok` (스택 전환과 무관하게 이름 고정 — M6 참고) |
| Require status checks | `plans-guard / tasks/index.json 검증` |
| Require status checks | `plans-guard / tasks/index.json Diff 보호` |
| Require status checks | `plans-guard / WIP↔Branch` |
| Require status checks | `plans-guard / Depends 검증` |
| Require status checks | `plans-guard / Acceptance Oracle` |
| Require status checks | `plans-guard / Task Granularity` |
| Require pull request | ✓ |
| Dismiss stale reviews | ✓ |

> `ci-ok`를 required check로 등록하면 `.github/workflows/ci.yml`의 스택
> 블록을 켜거나 잡을 바꿔도 이 이름은 안 바뀐다 — required check 재등록이
> 필요 없다. placeholder를 직접 등록하지 말 것(스택 활성화 시 이름이
> 사라져 영구 대기하게 된다).
>
> **branch protection을 켜면 아래 plans-complete.yml의 push도 함께
> 막힌다** — `plans-complete.yml`은 이 경우 자동으로 PR 폴백(자동 PR
> 생성 + auto-merge)으로 전환되지만, 폴백이 동작하려면 저장소 Settings →
> Actions에서 "Allow GitHub Actions to create and approve pull requests"와
> Settings → General → Pull Requests에서 "Allow auto-merge"가 켜져 있어야
> 한다(둘 다 기본값 꺼짐). 상세 근거: `.github/workflows/plans-complete.yml` 상단 주석.

---

## Step 3. CI 기술 스택 활성화

`.github/workflows/ci.yml` 열고 프로젝트 스택 블록 주석 해제:

```yaml
# 예: Node.js 프로젝트
# ── [STACK: Node.js / Bun] 블록 주석 해제 후 ──
check:
  name: Type check & lint
  ...
```

활성화 후 `placeholder` job 삭제 + `ci-ok`의 `needs:`를 `[check, test]`로
변경. **required check 이름(`ci-ok`)은 바꿀 필요 없음** — branch protection
재등록 없이 스택만 전환된다.

---

## Step 4. Planning 단계 사용법

```
/harness-plan
```

GitHub 연동 시 추가 동작:
1. `tasks/index.json`의 `section` → GitHub Milestone 생성
2. 각 Task 객체 → GitHub Issue 생성 (`[1.1] 내용` 형식)
3. `tasks/index.json`의 `gh` 값에 `#N` 자동 기입

직접 생성 시:
```bash
# Milestone
gh api repos/{owner}/{repo}/milestones -f title="Week 1" -f due_on="YYYY-MM-DDT00:00:00Z"

# Issue
gh issue create --title "[1.1] 기능 구현" --body "DoD: ..." --milestone "Week 1"
```

---

## Step 5. Implementation 단계 사용법

```
/harness-work
```

GitHub 연동 시 추가 동작:
1. Task 시작 → `task/{task-id}-{설명}` 브랜치 자동 생성
2. 구현 완료 → PR 자동 오픈 (`Closes #{issue}` 포함)
3. CI 통과 + 승인 → main 머지
4. 머지 이벤트에서 `plans-complete.yml` 봇이 `tasks/index.json`의 `wip → done`을
   반영해 자동 커밋(세션·worker가 PR 안에서 직접 바꾸지 않는다 —
   `wip-branch-check`와 모순되므로 금지)

직접 브랜치/PR 생성 시:
```bash
git checkout -b task/1.1-auth-login
# ... 구현 ...
git push -u origin task/1.1-auth-login
gh pr create \
  --title "[1.1] auth login 구현" \
  --body "Closes #5" \
  --base main
```

---

## plans-guard 동작 원리

PR → main 시 `plans-guard.yml`이 `tasks/index.json`만 기준으로 나머지 게이트를 실행한다.
`Plans.md` 동기화는 CI 조건이 아니다:

```
tasks/index.json 검증 (validate-tasks):
  JSON 스키마, 중복 ID, Depends 존재 여부, WIP Depends 완료 여부,
  Acceptance 누락 여부를 검증

WIP↔Branch (wip-branch-check):
  PR 브랜치명에서 task-id 추출 (task/{X.Y}-*)
  → tasks/index.json에서 해당 Task가 wip인지 확인
  → 아니면 CI 실패 (머지 차단)
  → task/* 형식이 아닌 브랜치(docs, hotfix 등)는 skip

tasks/index.json Diff 보호 (tasks-diff-check):
  base↔head 사이 tasks/index.json의 status 변경만 추출
  → PR 안에서 done으로 전환하면 무조건 실패(완료는 plans-complete 봇 전용)
  → todo→wip 전환은 자기 task/{id}-* 브랜치의 그 Task에서만 허용,
    비-task 브랜치나 타 Task 행 변경은 실패

Depends 검증 (depends-check):
  wip Task의 Depends가 가리키는 Task가 전부 done인지 확인
  → 선행 Task 미완료면 CI 실패

Acceptance Oracle (acceptance-check):
  tasks/index.json의 wip Task 각각의 Acceptance 명령을 실행
  → 하나라도 실패(exit ≠ 0)하면 CI 실패 (머지 차단)
  → fork PR에서는 실행하지 않음 (임의 명령 주입 방지)

Task Granularity (granularity-check):
  wip Task가 DoD/Depends 미기재·뭉뚱그린 표현 등 세분화 기준 미달이면 CI 실패
```

PR 브랜치의 Task가 `wip`이 아닌 경우 → `/harness-work`가 `tasks/index.json`을 갱신했는지 확인.

> **done은 PR 안에서 바꾸지 않는다.** 머지 이벤트에서 `plans-complete.yml`
> 봇이 `tasks/index.json`을 `wip → done`으로 전환한다(직접 main push 시도
> → branch protection에 막히면 PR 자동 생성 + auto-merge로 폴백). 세션이 PR
> 안에서 미리 done으로 바꾸면 `tasks-diff-check`가 차단한다.

---

## 자주 쓰는 명령어

```bash
gh issue list                          # 현재 이슈 목록
gh issue create --title "..." --body "..."
gh pr list                             # PR 목록
gh pr create --title "..." --body "Closes #N"
gh run list --workflow=ci.yml          # CI 실행 이력
gh run watch                           # CI 실시간 모니터링
```
