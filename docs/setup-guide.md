# Claude Code Harness 설정 가이드

새 프로젝트에 harness 템플릿을 적용하는 단계별 가이드.

---

## 사전 조건

- Claude Code CLI 설치됨
- Node.js 18+ (harness CLI 의존)
- GitHub 계정 (배포 선택 사항)

---

## Step 1. 전역 Plugin 설치 (최초 1회)

### 1-1. 자동 스크립트 실행 (권장)

`~/.claude/settings.json`을 손으로 편집하지 않는다 — 대신 스크립트가
기존 설정을 백업하고 필요한 값만 병합한다.

```bash
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
/tmp/harness-tpl/scripts/setup-plugins.sh
```

`~/.claude/settings.json`에 필수 plugin 3종(claude-code-harness·ponytail·caveman)을
등록(기존 설정은 백업 후 보존)하고, `claude plugin install`로 설치한 뒤,
`harness doctor`까지 자동 실행한다. 여러 번 실행해도 안전(멱등적)하다.

`value-for-fable`은 선택 plugin이다 — 대화형 터미널이면 설치 여부를 묻고,
무인 실행 시에는 아래처럼 명시한다.

```bash
./scripts/setup-plugins.sh --skip-vff   # value-for-fable 제외
./scripts/setup-plugins.sh --with-vff   # value-for-fable 포함
```

### 1-2. 수동 설치 (참고용)

자동 스크립트 대신 직접 하고 싶다면 (아래 `value-for-fable`/`itsinseong` 블록과
`claude plugin install value-for-fable@itsinseong`은 선택 사항이므로 원치 않으면 생략):

```json
{
  "enabledPlugins": {
    "claude-code-harness@claude-code-harness-marketplace": true,
    "ponytail@ponytail": true,
    "caveman@caveman": true,
    "value-for-fable@itsinseong": true
  },
  "extraKnownMarketplaces": {
    "claude-code-harness-marketplace": {
      "source": {
        "source": "github",
        "repo": "Chachamaru127/claude-code-harness"
      }
    },
    "ponytail": {
      "source": {
        "source": "github",
        "repo": "DietrichGebert/ponytail"
      }
    },
    "caveman": {
      "source": {
        "source": "github",
        "repo": "JuliusBrussee/caveman"
      }
    },
    "itsinseong": {
      "source": {
        "source": "git",
        "url": "https://github.com/itsinseong/value-for-fable.git"
      }
    }
  },
  "tui": "fullscreen",
  "theme": "dark"
}
```

```bash
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
claude plugin install value-for-fable@itsinseong  # 선택
```

### 1-3. 설치 확인

```bash
harness doctor
```

전체 항목이 통과되면 완료 (자동 스크립트를 썼다면 이미 실행됨).

---

## Step 2. 새 프로젝트에 템플릿 적용

### 2-1. 이 레포 클론 후 파일 복사

```bash
# 새 프로젝트 디렉토리로 이동
cd /path/to/my-new-project

# 템플릿 파일 복사
cp /path/to/cc-harness-template/harness.toml .
cp /path/to/cc-harness-template/CLAUDE.md .
cp /path/to/cc-harness-template/AGENTS.md .
cp /path/to/cc-harness-template/templates/skeleton/Plans.md .
cp -r /path/to/cc-harness-template/templates/skeleton/tasks .
cp -r /path/to/cc-harness-template/scripts .
cp /path/to/cc-harness-template/BLUEPRINT.md .
mkdir -p .agents
cp -r /path/to/cc-harness-template/.agents/skills .agents/
mkdir -p .claude
cp -r /path/to/cc-harness-template/.claude/commands .claude/
mkdir -p .claude/skills
cp -r /path/to/cc-harness-template/.claude/skills/grill-me .claude/skills/
mkdir -p .claude/agent-memory/claude-code-harness-worker
mkdir -p .claude/agent-memory/claude-code-harness-reviewer
mkdir -p .claude/agent-memory/claude-code-harness-advisor
cp /path/to/cc-harness-template/.claude/agent-memory/claude-code-harness-worker/MEMORY.md \
   .claude/agent-memory/claude-code-harness-worker/
cp /path/to/cc-harness-template/.claude/agent-memory/claude-code-harness-reviewer/MEMORY.md \
   .claude/agent-memory/claude-code-harness-reviewer/
cp /path/to/cc-harness-template/.claude/agent-memory/claude-code-harness-advisor/MEMORY.md \
   .claude/agent-memory/claude-code-harness-advisor/
cp /path/to/cc-harness-template/.claude/settings.local.json.example .claude/settings.local.json
```

### 2-2. 프로젝트별 커스터마이징

**harness.toml**
```toml
[project]
name = "my-actual-project-name"   # ← 변경
description = "프로젝트 설명"      # ← 변경
```

**CLAUDE.md** — `[PROJECT_NAME]`, 기술 스택, 코딩 규칙 섹션 채우기.

**AGENTS.md** — Codex가 같은 규약을 읽는 진입점. `[PROJECT_NAME]`을 확인하고,
프로젝트별로 Codex에만 필요한 예외가 있으면 `CLAUDE.md`와 드리프트 없이 함께 기록한다.

**.agents/skills/** — Codex repo-scoped skills. `$harness-work`, `$branch-checkout`,
`$git-push`, `$pr-create` 등으로 호출한다.

**.claude/commands/** — Claude Code local custom commands. `/branch-checkout`,
`/git-push`, `/pr-create`를 제공한다.

**tasks/index.json** — Week 구조와 Task 상태 단일 출처. DoD는 검증 가능한 기준으로 작성.
사람이 읽는 로드맵이 필요하면 `python3 scripts/sync_plans.py`로 **Plans.md** snapshot을 갱신한다.

**agent-memory/*.md** — `## Project Context` 섹션에 프로젝트 이름과 PRD 경로 입력.

### 2-3. harness 초기화

```bash
harness sync
harness doctor
```

---

## Step 3. GitHub 연동 (선택)

GitHub로 코드 변경사항을 관리하려면:

### 3-1. 사전 조건 확인

```bash
gh auth login          # GitHub CLI 로그인
git remote -v          # 원격 repo 연결 확인
```

### 3-2. harness.toml 활성화

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

### 3-3. CI 스택 블록 활성화

`.github/workflows/ci.yml`에서 프로젝트 기술 스택 블록 주석 해제.
`placeholder` job 삭제 후 `ci-ok`의 `needs:`를 활성화한 스택 잡으로 업데이트.

### 3-4. Branch Protection 설정

GitHub → Settings → Branches → main:
- Require status checks: `ci-ok`, `plans-guard / tasks/index.json 검증`, `plans-guard / Plans.md sync 검증`
- Require pull request before merging

> 상세 가이드: `docs/github-integration.md`

---

## Step 4. 작업 시작

### tasks/index.json에 Task 추가

```
/harness-plan
```

### Task 실행 (worker 팀 가동)

```
/harness-work
```

### 진행 상황 확인

```
/harness-progress
/harness-sync
```

---

## 자주 쓰는 명령어 치트시트

| 명령어 | 동작 |
|--------|------|
| `harness doctor` | 설치 상태 점검 |
| `harness sync` | toml → plugin 파일 동기화 |
| `/harness-plan` | Task 추가·관리 |
| `/harness-work` | Task 실행 |
| `/harness-review` | 코드 리뷰 |
| `/harness-progress` | 진행 대시보드 |
| `/caveman lite\|full\|ultra` | 압축 강도 조절 |
| `/ponytail lite\|full\|ultra` | lazy mode 강도 조절 |
| `/itsvff` | VFF 세션 모드 활성화 |
| `gh issue list` | GitHub 이슈 목록 |
| `gh pr list` | GitHub PR 목록 |
| `gh run watch` | CI 실행 실시간 모니터링 |

---

## 문제 해결

### `harness doctor` 항목 실패 시

```bash
# plugin 재설치
claude plugin uninstall claude-code-harness@claude-code-harness-marketplace
claude plugin install claude-code-harness@claude-code-harness-marketplace
harness sync
```

### worker가 caveman full로 응답할 때

worker MEMORY.md의 `### caveman: lite 모드` 섹션이 제대로 작성됐는지 확인.
Claude Code 재시작 후 재시도.

### Task가 선택되지 않을 때

Task status가 `tasks/index.json`에서 `todo`인지 확인. `wip`는 이미 진행 중으로 간주됨.
