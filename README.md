# cc-harness-template

Claude Code Harness + ponytail + caveman + value-for-fable 조합 프로젝트 템플릿.

새 프로젝트를 시작할 때 이 레포를 기점으로 구성하면, 세션 시작부터
worker/reviewer/advisor 에이전트 규칙까지 즉시 사용 가능한 상태가 된다.

---

## 이 템플릿이 제공하는 것

| 파일 | 역할 |
|------|------|
| `harness.toml` | Harness 프로젝트 설정 (안전 규칙 포함) |
| `CLAUDE.md` | Claude Code 전역 프로젝트 규칙 템플릿 |
| `Plans.md` | Task 관리 시트 템플릿 (cc:TODO/WIP/완료 마커) |
| `BLUEPRINT.md` | 시스템 아키텍처 전체 설명 |
| `.claude/settings.local.json` | 프로젝트 스코프 권한 설정 |
| `.claude/agent-memory/claude-code-harness-worker/MEMORY.md` | Worker 에이전트 규칙 |
| `.claude/agent-memory/claude-code-harness-reviewer/MEMORY.md` | Reviewer 에이전트 규칙 |
| `.claude/agent-memory/claude-code-harness-advisor/MEMORY.md` | Advisor 에이전트 규칙 |
| `docs/setup-guide.md` | 단계별 설치·적용 가이드 |
| `docs/global-settings-reference.md` | `~/.claude/settings.json` 레퍼런스 |

---

## 빠른 시작

### 1. 전역 Plugin 설치 (최초 1회)

`~/.claude/settings.json`에 아래 추가:

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
      "source": { "source": "github", "repo": "Chachamaru127/claude-code-harness" }
    },
    "ponytail": {
      "source": { "source": "github", "repo": "DietrichGebert/ponytail" }
    },
    "caveman": {
      "source": { "source": "github", "repo": "JuliusBrussee/caveman" }
    },
    "itsinseong": {
      "source": { "source": "git", "url": "https://github.com/itsinseong/value-for-fable.git" }
    }
  }
}
```

```bash
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
claude plugin install value-for-fable@itsinseong
```

### 2. 새 프로젝트에 적용

```bash
cd /path/to/my-new-project
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl

# 템플릿 파일 복사
cp /tmp/harness-tpl/harness.toml .
cp /tmp/harness-tpl/CLAUDE.md .
cp /tmp/harness-tpl/Plans.md .
cp /tmp/harness-tpl/BLUEPRINT.md .
mkdir -p .claude/agent-memory/{claude-code-harness-worker,claude-code-harness-reviewer,claude-code-harness-advisor}
cp /tmp/harness-tpl/.claude/agent-memory/claude-code-harness-worker/MEMORY.md .claude/agent-memory/claude-code-harness-worker/
cp /tmp/harness-tpl/.claude/agent-memory/claude-code-harness-reviewer/MEMORY.md .claude/agent-memory/claude-code-harness-reviewer/
cp /tmp/harness-tpl/.claude/agent-memory/claude-code-harness-advisor/MEMORY.md .claude/agent-memory/claude-code-harness-advisor/
cp /tmp/harness-tpl/.claude/settings.local.json .claude/
```

### 3. 프로젝트에 맞게 커스터마이징

- `harness.toml` → `name`, `description` 변경
- `CLAUDE.md` → 기술 스택, 코딩 규칙 채우기
- `Plans.md` → Week/Task 정의 (DoD는 검증 가능한 기준으로)
- `agent-memory/*/MEMORY.md` → `## Project Context` 섹션 채우기

```bash
harness sync
harness doctor   # 전체 통과 확인
```

### 4. 작업 시작

```bash
# Claude Code 열기
claude

# Task 추가
/harness-plan

# 실행
/harness-work
```

---

## 아키텍처

시스템 전체 구조는 [BLUEPRINT.md](./BLUEPRINT.md) 참조.
설치 상세 절차는 [docs/setup-guide.md](./docs/setup-guide.md) 참조.
전역 설정 레퍼런스는 [docs/global-settings-reference.md](./docs/global-settings-reference.md) 참조.

---

## Plugin 버전 (이 템플릿 작성 기준)

| Plugin | 버전 | 소스 |
|--------|------|------|
| claude-code-harness | 4.16.3 | Chachamaru127/claude-code-harness |
| ponytail | 4.8.3 | DietrichGebert/ponytail |
| caveman | 25d22f8 | JuliusBrussee/caveman |
| value-for-fable | 1.0.1 | itsinseong/value-for-fable |

---

## Agent 규칙 매트릭스

| | worker | reviewer | advisor |
|--|:------:|:--------:|:-------:|
| **ponytail** | 전체 | 전체 | 전체 |
| **caveman** | lite | OFF | OFF |
| **VFF v2** | 검증·코드 규율만 | 전체 | 전체 |

상세 설명: [BLUEPRINT.md §2](./BLUEPRINT.md#2-agent-layer-per-agent-규칙)
