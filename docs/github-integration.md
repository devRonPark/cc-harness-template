# GitHub 통합 가이드

harness 템플릿의 GitHub 연동은 Issue/PR 추적과 검증 CI만 맡는다.
`tasks/index.json`의 `todo`/`wip`/`done` 상태는 세션 에이전트가 직접 관리하며,
GitHub Actions는 Task 상태를 변경하지 않는다.

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
| Require status checks | `ci-ok` |
| Require status checks | `plans-guard / tasks/index.json 검증` |
| Require status checks | `plans-guard / Plans.md sync 검증` |
| Require pull request | ✓ |
| Dismiss stale reviews | ✓ |

`ci-ok`를 required check로 등록하면 `.github/workflows/ci.yml`의 스택 블록을
켜거나 잡을 바꿔도 이 이름은 유지된다. Task 상태 관련 check는 더 이상 필수로
두지 않는다.

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
변경. required check 이름(`ci-ok`)은 바꿀 필요 없다.

---

## Step 4. Planning 단계 사용법

```text
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

```text
/harness-work
```

GitHub 연동 시에도 상태 전환은 세션 에이전트가 수행한다:

1. Task 시작 → `task/{task-id}-{설명}` 브랜치 생성
2. 대상 Task를 `wip`로 갱신하고 `python3 scripts/sync_plans.py` 실행
3. 구현 + Acceptance + 관련 테스트 통과
4. 대상 Task를 `done`으로 갱신하고 `python3 scripts/sync_plans.py` 실행
5. PR 오픈 (`Closes #{issue}` 포함)
6. `ci-ok` + `plans-guard` 통과 + 승인 후 main 머지

직접 브랜치/PR 생성 시:

```bash
git checkout -b task/1.1-auth-login
# ... 구현 및 검증 ...
git push -u origin task/1.1-auth-login
gh pr create \
  --title "[1.1] auth login 구현" \
  --body "Closes #5" \
  --base main
```

---

## plans-guard 동작 원리

PR → main 시 `plans-guard.yml`은 쓰기 없는 검증만 수행한다.

```text
tasks/index.json 검증:
  JSON 스키마, 중복 ID, Depends 존재 여부, 상태 값, blocked_reason 등
  manifest 품질을 scripts/validate_tasks.py로 검증

Plans.md sync 검증:
  python3 scripts/sync_plans.py --check
  tasks/index.json에서 생성된 읽기용 snapshot과 현재 Plans.md가 일치하는지 확인
```

`plans-guard`는 브랜치명과 WIP 상태를 맞추거나, Acceptance 명령을 실행하거나,
Task 상태 변경 범위를 제한하지 않는다. 그 판단과 실행은 `CLAUDE.md`,
`agents/task-decomposer.md`, `agents/test-agent.md`, `agents/quality-gates.md`를
따르는 세션 에이전트 책임이다.

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
