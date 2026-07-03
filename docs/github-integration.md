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
| Require status checks | `placeholder` (ci.yml 활성화 후 실제 job명으로 변경) |
| Require status checks | `plans-guard / WIP↔Branch` |
| Require status checks | `plans-guard / Acceptance Oracle` |
| Require pull request | ✓ |
| Dismiss stale reviews | ✓ |

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

활성화 후 `placeholder` job 삭제 + branch protection 상태 체크명 업데이트.

---

## Step 4. Planning 단계 사용법

```
/harness-plan
```

GitHub 연동 시 추가 동작:
1. Plans.md `## Week N` → GitHub Milestone `Week N` 생성
2. 각 Task → GitHub Issue 생성 (`[1.1] 내용` 형식)
3. Plans.md `GH` 컬럼에 `#N` 자동 기입

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
4. Plans.md `cc:WIP → cc:완료` 자동 업데이트

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

PR → main 시 `plans-guard.yml`이 자동 실행:

```
WIP↔Branch:
  PR 브랜치명에서 task-id 추출 (task/{X.Y}-*)
  → Plans.md에서 해당 Task가 cc:WIP인지 확인
  → 아니면 CI 실패 (머지 차단)
  → task/* 형식이 아닌 브랜치(docs, hotfix 등)는 skip

Acceptance Oracle:
  Plans.md의 cc:WIP Task 각각의 Acceptance 명령을 실행
  → 하나라도 실패(exit ≠ 0)하면 CI 실패 (머지 차단)
  → fork PR에서는 실행하지 않음 (임의 명령 주입 방지)
```

PR 브랜치의 Task가 `cc:WIP`이 아닌 경우 → `/harness-work`가 마커를 갱신했는지 확인.

> **cc:완료 갱신 시점 주의**: branch protection으로 main 직접 push를 막으면
> 머지 후 Plans.md 마커 갱신도 커밋이 필요하다. 갱신 커밋을 **task PR 마지막
> 커밋에 포함**시키거나(머지와 동시에 완료 처리), 다음 task 브랜치에서 함께
> 반영하는 방식 중 하나를 팀 규칙으로 정해둘 것.

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
