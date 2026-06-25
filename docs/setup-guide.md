# Claude Code Harness 설정 가이드

새 프로젝트에 harness 템플릿을 적용하는 단계별 가이드.

---

## 사전 조건

- Claude Code CLI 설치됨
- Node.js 18+ (harness CLI 의존)
- GitHub 계정 (배포 선택 사항)

---

## Step 1. 전역 Plugin 설치 (최초 1회)

### 1-1. `~/.claude/settings.json` 수정

아래 내용을 `~/.claude/settings.json`에 추가한다.
파일이 없으면 새로 만든다.

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

### 1-2. Plugin 설치

```bash
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
claude plugin install value-for-fable@itsinseong
```

### 1-3. 설치 확인

```bash
harness doctor
```

전체 항목이 통과되면 완료.

---

## Step 2. 새 프로젝트에 템플릿 적용

### 2-1. 이 레포 클론 후 파일 복사

```bash
# 새 프로젝트 디렉토리로 이동
cd /path/to/my-new-project

# 템플릿 파일 복사
cp /path/to/cc-harness-template/harness.toml .
cp /path/to/cc-harness-template/CLAUDE.md .
cp /path/to/cc-harness-template/Plans.md .
cp /path/to/cc-harness-template/BLUEPRINT.md .
mkdir -p .claude/agent-memory/claude-code-harness-worker
mkdir -p .claude/agent-memory/claude-code-harness-reviewer
mkdir -p .claude/agent-memory/claude-code-harness-advisor
cp /path/to/cc-harness-template/.claude/agent-memory/claude-code-harness-worker/MEMORY.md \
   .claude/agent-memory/claude-code-harness-worker/
cp /path/to/cc-harness-template/.claude/agent-memory/claude-code-harness-reviewer/MEMORY.md \
   .claude/agent-memory/claude-code-harness-reviewer/
cp /path/to/cc-harness-template/.claude/agent-memory/claude-code-harness-advisor/MEMORY.md \
   .claude/agent-memory/claude-code-harness-advisor/
cp /path/to/cc-harness-template/.claude/settings.local.json .claude/
```

### 2-2. 프로젝트별 커스터마이징

**harness.toml**
```toml
[project]
name = "my-actual-project-name"   # ← 변경
description = "프로젝트 설명"      # ← 변경
```

**CLAUDE.md** — `[PROJECT_NAME]`, 기술 스택, 코딩 규칙 섹션 채우기.

**Plans.md** — Week 구조와 Task 정의. DoD는 검증 가능한 기준으로 작성.

**agent-memory/*.md** — `## Project Context` 섹션에 프로젝트 이름과 PRD 경로 입력.

### 2-3. harness 초기화

```bash
harness sync
harness doctor
```

---

## Step 3. 작업 시작

### Plans.md에 Task 추가

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

### Plans.md Task가 선택되지 않을 때

Task Status가 `cc:TODO`인지 확인. `cc:WIP`는 이미 진행 중으로 간주됨.
