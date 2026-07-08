# cc-harness-template

**Claude Code / Codex Agent Harness Template** — Claude Code와 Codex가 같은 프로젝트
맥락을 안정적으로 유지하고, 계획·구현·검증·리뷰를 역할별로 나누고, 세션이 끊겨도
복구할 수 있게 만드는 repo-level 템플릿.

> Claude Code 또는 Codex로 개발할 때, 매번 처음부터 설정하지 않아도 되도록 만든 개인 환경 템플릿.

---

## 먼저 고를 것

이 템플릿은 두 실행 환경을 모두 지원한다. 처음에는 아래 중 하나만 고르면 된다.

| 내가 쓰는 도구 | 먼저 할 일 | 핵심 진입점 |
|---|---|---|
| Claude Code | [Claude Code Setup](#claude-code-setup)으로 플러그인 설치 후 `claude` 실행 | `CLAUDE.md`, `/harness-*`, `/grill-me` |
| Codex | [Codex CLI Setup](#codex-cli-setup) 확인 후 `codex` 실행 | `AGENTS.md`, `.agents/skills/*`, `$harness-*` |
| 둘 다 | Claude Code 플러그인을 설치하고 Codex는 repo 규칙을 직접 실행 | `CLAUDE.md`를 기준으로 `AGENTS.md`가 호환 절차 제공 |

새 프로젝트에 바로 적용하려면 아래 Quick Start부터 실행한다. 이미 코드와 README가
있는 프로젝트라면 [기존 프로젝트에 적용](#기존-프로젝트에-적용)으로 건너뛴다.

## Quick Start

```bash
# 1. 템플릿 클론
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl

# 2. 내 프로젝트에 적용
/tmp/harness-tpl/init.sh /path/to/my-project

# 3. 프로젝트로 이동
cd /path/to/my-project
```

이후 사용할 도구를 실행한다.

```bash
claude  # Claude Code
codex   # Codex
```

복사 직후엔 `harness.toml`·`CLAUDE.md`가 플레이스홀더 상태다.
[커스터마이징 체크리스트](#step-2--커스터마이징-체크리스트)를 먼저 채워야
AI가 엉뚱한 컨텍스트로 동작하지 않는다.

## Codex CLI Setup

Codex는 Claude Code 플러그인 hook을 자동 실행하지 않는다. 대신 이 저장소의
루트 `AGENTS.md`와 `.agents/skills/`가 같은 절차를 Codex 방식으로 제공한다.

Codex에서 새 세션을 열면 아래 순서로 시작한다.

```text
AGENTS.md를 읽어줘.
tasks/index.json과 Plans.md 기준으로 현재 상태를 확인해줘.
$harness-progress로 진행 상황을 요약해줘.
```

작업을 실행할 때는 Claude Code slash command 대신 Codex skill 이름을 쓴다.

| 목적 | Codex에서 호출 | 하는 일 |
|---|---|---|
| 기획 인터뷰 | `$grill-me` | PRD 초안과 Open Questions 정리 |
| Task 추가 | `$harness-plan` | planning context → proposal → 검증 → `tasks/index.json` 반영 |
| Task 구현 | `$harness-work` | 세분화/scope 게이트 → 구현 → Acceptance/test → 리뷰 |
| 진행 확인 | `$harness-progress` | `tasks/index.json` 기준 읽기 전용 요약 |
| Plans sync | `$harness-sync` | `tasks/index.json` 검증과 `Plans.md` 재생성 |
| Git 작업 | `$branch-checkout`, `$git-push`, `$pr-create`, `$rescue-from-main` | 브랜치, push, PR, main 작업 구조 |

Codex 작업도 항상 `agents/quality-gates.md`를 따른다. ponytail/caveman plugin
자동 hook이 없으므로 YAGNI, scope check, findings-first 리뷰는 Codex 세션이 직접
적용한다.

## 작업별 Workflow

| 하고 싶은 일 | 시작 명령 | 완료 전 확인 |
|---|---|---|
| 새 기능 기획 | Claude: `/grill-me` / Codex: `$grill-me` | `docs/PRD.md`와 Open Questions가 남았는지 확인 |
| Task 추가 | Claude: `/harness-plan` / Codex: `$harness-plan` | `validate_task_proposal.py`, `validate_tasks.py`, `sync_plans.py --check` 통과 |
| Task 구현 | Claude: `/harness-work` / Codex: `$harness-work` | Task Acceptance 명령과 관련 테스트 통과 |
| 현재 diff 리뷰 | Claude: `/harness-review` / Codex: `$harness-review` | findings-first 리뷰에서 blocker 없음 |
| 진행률 확인 | Claude: `/harness-progress` / Codex: `$harness-progress` | `tasks/index.json` 기준으로 `wip`/`todo` 확인 |
| 작업 브랜치 만들기 | Claude: `/branch-checkout` / Codex: `$branch-checkout` | `git status`가 깨끗한지 확인 후 전환 |
| PR 준비 | Claude: `/git-push`, `/pr-create` / Codex: `$git-push`, `$pr-create` | Acceptance evidence와 리뷰 결과를 PR 본문에 반영 |

---

## 이 템플릿이 해결하는 문제 (Why)

Claude Code로 새 프로젝트를 시작할 때마다 반복되는 일이 있다.

- AI가 불필요한 추상화나 과잉 구현을 한다
- 응답이 너무 길어서 읽는 데 시간이 걸린다
- 구현·리뷰·방향 결정을 같은 AI에게 시키면 역할이 뒤섞인다
- 할 일 목록과 실제 구현 상태가 어긋난다
- 터미널 세션이 끊기면 어디까지 했는지 다시 파악해야 한다
- 같은 에러를 원인 파악 없이 반복한다
- 프로젝트별 규칙이 `CLAUDE.md`에 정리돼 있지 않아 작업 품질이 세션마다 흔들린다

이 템플릿은 이 문제들을 **4개 Claude Code 플러그인 + `CLAUDE.md` 규약 +
Codex용 `AGENTS.md` 진입점 + `.harness/` 상태 문서** 조합으로 해결한다.
새 프로젝트에 복사하고 이름만 바꾸면 바로 쓸 수 있다.

---

## 이 템플릿에 포함된 것 (What You Get)

`CLAUDE.md`가 이 템플릿의 핵심 — Claude Code가 세션마다 가장 먼저 읽는 프로젝트 운영 규칙이다.
아래는 이 저장소에 실제로 있는 파일 기준. 없는 것을 있는 것처럼 적지 않는다.

| 경로 | 상태 | 용도 |
|---|---|---|
| `CLAUDE.md` | 포함 | Claude Code가 항상 먼저 읽는 프로젝트 규칙 (플레이스홀더 — 프로젝트마다 채워야 함) |
| `AGENTS.md` | 포함 | Codex가 자동으로 읽는 프로젝트 규칙 진입점. `CLAUDE.md` 규약을 Codex 절차로 실행 |
| `harness.toml` | 포함 | 프로젝트 이름·안전 규칙 + `[github]`/`[review]`/`[test]`/`[plan]` 요약 인덱스 (실행 SSOT는 CLAUDE.md) |
| `tasks/index.json` | 포함 | Task 상태 단일 출처 (`todo`/`wip`/`done`/`blocked` + DoD·Acceptance·Depends·GH) |
| `Plans.md` | 포함 | 사람이 필요할 때 갱신하는 읽기용 Task snapshot. stale일 수 있으며 직접 편집하지 않음 |
| `BLUEPRINT.md` | 포함 | 플러그인·에이전트 협력 구조 전체 설명 (읽기용) |
| `agents/task-decomposer.md`, `agents/test-agent.md`, `agents/quality-gates.md` | 포함 | 세분화 게이트·런타임 검증·공통 scope/YAGNI/review/reporting 기준. task-decomposer는 `/harness-plan`에서 외부 명령 계약 기반 proposal 흐름을 기본으로 사용 |
| `.harness/` (STATE·HANDOFF·TASKS·LOG·LESSONS·CHECKPOINTS·CONTEXT_INDEX) | 포함 | 세션 상태·에러 이력·인수인계 기록 |
| `.agents/skills/*/SKILL.md` | 포함 | Codex repo-scoped skills (`$grill-me`, `$harness-plan`, `$harness-work`, `$harness-review`, `$harness-progress`, `$harness-sync`, `$branch-checkout`, `$git-push`, `$pr-create`, `$rescue-from-main`) |
| `.claude/commands/{branch-checkout,git-push,pr-create,rescue-from-main}.md` | 포함 | Claude Code custom commands for Git branch checkout, safe push, draft PR creation, main/master work rescue |
| `.claude/skills/grill-me/SKILL.md` | 포함 | 인터뷰 기반 PRD 초안 작성 스킬 (`/grill-me`) |
| `.claude/agent-memory/*/MEMORY.md` | 포함 | worker·reviewer·advisor 행동 규칙 주입 (caveman/VFF 적용 강도 지정) |
| `docs/templates/{PRD,UserFlow,DESIGN,Architecture}.md` | 포함 | 기획 산출물 골격 |
| `.github/workflows/{ci,plans-guard}.yml` | 포함 | 기술 스택 CI + Task manifest/snapshot 검증 (GitHub 연동 시) |
| `init.sh` | 포함 | 위 전체를 새 프로젝트 디렉토리에 한 번에 복사 |
| `scripts/setup-plugins.sh` | 포함 | `~/.claude/settings.json` 플러그인 등록·설치 자동화 (Step 1 수동 JSON 편집 대체) |
| `.claude/settings.local.json.example` | 포함(예시) | 프로젝트 전용 권한 설정 — 복사 후 `settings.local.json`으로 rename |
| `LICENSE` | 포함 (MIT) | — |
| `.claude/settings.json` (hooks) | **미포함 — 추가 권장** | 파일 수정 후 검증 자동화 등 (아래 [Hooks](#claude-code-hooks) 참고) |
| `.claude/commands/` | 일부 포함 | Git helper custom commands만 포함. `/harness-*` 명령은 로컬 파일이 아니라 설치된 플러그인이 제공 |
| `scripts/{validate_tasks,report_tasks,sync_plans,build_planning_context,validate_task_proposal,apply_task_proposal}.py` | 포함 | Task JSON 검증·진행률 출력·planning proposal·읽기용 Plans.md snapshot 생성 |
| `scripts/verify-harness.sh` | **미포함** | 대체 수단: `harness doctor` (설치 상태) + `tasks/index.json`의 Task별 Acceptance 명령 (기능 검증) |

---

## 구성 요소 한눈에 보기

이 템플릿은 **필수 Plugin 3개** + **선택 Plugin 1개** + **5개 에이전트 규칙** +
**프로젝트 설정 파일**로 이루어진다.

### Plugin 3개(필수) — 세션 시작 시 자동으로 켜진다

| Plugin | 한 줄 설명 |
|--------|-----------|
| **claude-code-harness** | `tasks/index.json`/Plans.md를 기준으로 할 일을 worker·reviewer·advisor에게 나눠준다 |
| **ponytail** | 코드를 쓰기 전에 "이게 정말 필요한가?"를 7단계로 확인하게 만든다 |
| **caveman** | AI 응답의 군더더기를 제거해 토큰을 약 65% 줄인다 |

ponytail/caveman은 Claude Code에서만 자동 hook으로 동작하는 plugin enhancement다.
Codex에는 같은 플러그인 자동 동작이 없으므로 `.agents/skills/*`가
`agents/quality-gates.md`를 직접 참조해 YAGNI, scope check, findings-first 리뷰,
짧은 검증 중심 보고 원칙을 적용한다.

### Plugin 1개(선택) — 개인 취향에 따라 설치 여부를 고른다

| Plugin | 한 줄 설명 |
|--------|-----------|
| **value-for-fable** | Sonnet 모델에 Fable 5 수준의 진단 규율을 적용한다. `setup-plugins.sh` 실행 시 설치 여부를 묻는다 (`--skip-vff`/`--with-vff`로 무인 지정 가능) |

### 에이전트 5종 — 계획·구현 단계에서 자동으로 협업한다

```
계획 → task-decomposer (PRD를 실행 가능한 최소 Task로 분해 — /harness-plan 필수 선행 단계)

구현 → harness → advisor       (방향 결정)
               → [게이트] task-decomposer + quality-gates 재확인 — 세분화/scope/YAGNI 기준 미달이면 worker 진입 차단
               → worker        (구현)
               → test-agent    (런타임 검증 — Acceptance + 테스트 스위트)
               → reviewer      (검토)
```

각 에이전트는 서로 다른 Plugin 조합으로 동작한다.
worker는 토큰을 아끼면서 구현하고, reviewer와 advisor는 판단 근거를 압축하지 않는다.

| | worker | reviewer | advisor | test-agent | task-decomposer |
|--|:------:|:--------:|:-------:|:----------:|:----------------:|
| ponytail (과잉 구현 방지) | ✅ | ✅ | ✅ | — | ✅ |
| caveman (응답 압축) | lite | — | — | — | — |
| VFF v2 (진단 구조) | 검증만 | ✅ 전체 | ✅ 전체 | — | — |
| `agents/quality-gates.md` (공통 기준) | ✅ | ✅ | ✅ | — | ✅ |

---

## Claude Code Setup

### 사전 조건

- [Claude Code CLI](https://claude.ai/code) 설치됨
- Node.js 18 이상 (`node --version`으로 확인)

### Step 1 — 플러그인 등록 + 설치 (자동)

`~/.claude/settings.json`을 손으로 편집하지 않는다 — JSON 문법 실수 한 번으로
Claude Code 전체 설정이 깨질 수 있다. 대신 스크립트를 실행한다.

```bash
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
/tmp/harness-tpl/scripts/setup-plugins.sh
```

이 스크립트가 하는 일:

1. `~/.claude/settings.json`이 없으면 새로 만들고, 있으면 백업(`settings.json.bak.<시각>`)한 뒤
   기존 내용을 보존한 채 이 템플릿이 필요로 하는 plugin만 병합한다
   (다른 plugin·permissions·theme 설정은 건드리지 않는다).
2. 필수 3종(claude-code-harness·ponytail·caveman)은 항상 설치한다.
   선택 plugin인 value-for-fable은 대화형 터미널이면 설치 여부를 묻고,
   `--skip-vff`/`--with-vff` 플래그나 `SETUP_SKIP_VFF=1` 환경변수로 무인 지정할 수 있다.
3. `harness doctor`로 설치 상태를 확인한다.

`claude`/`harness` CLI가 아직 없으면 해당 단계만 건너뛰고 안내 메시지를 출력한다 —
설치 후 다시 실행하면 된다(멱등적이라 여러 번 실행해도 안전).

```bash
./scripts/setup-plugins.sh --skip-vff   # value-for-fable 제외
./scripts/setup-plugins.sh --with-vff   # value-for-fable 포함 (프롬프트 생략)
```

<details>
<summary>수동으로 편집하고 싶다면 (참고용)</summary>

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
  },
  "tui": "fullscreen",
  "theme": "dark"
}
```

`value-for-fable` 블록(enabledPlugins·extraKnownMarketplaces 양쪽 모두)은 선택 사항이다 —
설치하지 않으려면 통째로 빼면 된다.

이후 필수 3종을 개별 설치한다 (value-for-fable은 원할 때만 추가로 설치).

```bash
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
claude plugin install value-for-fable@itsinseong  # 선택
```

</details>

### Step 2 — 설치 확인

```bash
harness doctor
```

모든 항목에 체크가 붙으면 완료 (setup-plugins.sh를 썼다면 이미 자동 실행됨).

### 첫 프롬프트

프로젝트에 `claude`로 진입한 직후, 아래를 그대로 붙여넣는다.

```text
Read CLAUDE.md first.
Then check harness.toml, tasks/index.json, Plans.md, and BLUEPRINT.md.
Follow the harness rules in CLAUDE.md: the planning gate (task-decomposer)
before writing Task rows, the test gate (test-agent) before review, and the
.harness/ state-doc rules.
Before making risky changes, update .harness/tasks/<task-key>/STATE.md.
Apply agents/quality-gates.md before implementation and review.
After implementation, run the Acceptance command recorded for the task in tasks/index.json.
If an error occurs and you fix it, record the cause and prevention rule in
.harness/tasks/<task-key>/LOG.md and .harness/LESSONS.md.
```

한국어 버전:

```text
먼저 CLAUDE.md를 읽어줘.
그다음 harness.toml, tasks/index.json, Plans.md, BLUEPRINT.md를 확인해줘.
CLAUDE.md의 harness 규칙을 따라줘 — Task 작성 전 task-decomposer 세분화 게이트,
리뷰 전 test-agent 검증 게이트, .harness/ 상태 문서 규칙 전부 포함.
위험한 변경 전에는 .harness/tasks/<task-key>/STATE.md를 갱신해줘.
구현과 리뷰 전에는 agents/quality-gates.md의 scope/YAGNI/review gate를 적용해줘.
구현 후에는 tasks/index.json에 기록된 해당 Task의 Acceptance 명령을 실행해줘.
에러가 발생했고 해결했다면 원문은 .harness/tasks/<task-key>/LOG.md에,
재발 방지 규칙은 .harness/LESSONS.md에 기록해줘.
```

---

## 새 프로젝트에 적용

빈 프로젝트(또는 이제 막 시작하는 프로젝트)에 이 템플릿을 통째로 적용하는 경우.
기존 코드가 이미 있는 프로젝트라면 [기존 프로젝트에 적용](#기존-프로젝트에-적용)을 본다.

### Step 1 — 템플릿 파일 복사

`init.sh`가 아래 모든 파일(CI 워크플로 2종, PR/Issue 템플릿, `.harness/` 골격
7종 포함)을 한 번에 복사한다. `tasks/index.json`·`Plans.md`·`.harness/`는 이 템플릿 저장소
자신의 작업 이력이 아니라 `templates/skeleton/`의 깨끗한 초기 상태에서
복사되므로, 새 프로젝트가 남의 완료 Task를 물려받지 않는다.

```bash
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
/tmp/harness-tpl/init.sh /path/to/my-new-project
```

### Step 2 — 커스터마이징 체크리스트

복사 후 반드시 아래 항목을 채워야 한다. 비워두면 AI가 엉뚱한 컨텍스트로 동작한다.

**`harness.toml`**
```toml
[project]
name = "my-actual-project"   # ← 이 프로젝트 이름으로 변경
description = "한 줄 설명"    # ← 변경
```

**`CLAUDE.md`**
`[PROJECT_NAME]`, 기술 스택, 디렉토리 구조, 코딩 규칙 섹션을 실제 프로젝트에 맞게 채운다.

**`tasks/index.json`**
Week 구조와 Task를 정의한다. DoD는 **검증 가능한 형태**로, Acceptance는
**세션 에이전트가 완료 전 실행할 명령어**로 쓴다. 사람이 읽는 로드맵이 필요하면
`python3 scripts/sync_plans.py`로 `Plans.md` snapshot을 갱신한다.

```markdown
# 좋은 DoD / Acceptance 예시
DoD: `npm run build` 에러 0, dist/index.js 존재
Acceptance: npm run build 2>&1 | grep -v error   ← 세션 에이전트가 실행, 실패 시 done 전환 금지

# 성공 판단 기준
- Task는 INVEST 기준으로 독립 검증 가능, 관찰 가능한 가치, 1 PR 이내, 테스트 가능해야 한다.
- DoD는 Definition of Done: 완료 후 관찰 가능한 상태를 쓴다.
- Acceptance는 Given/When/Then의 Then을 기계화한 oracle: exit 0, 파일 존재, 출력 매칭,
  HTTP 응답, 테스트 통과 중 하나로 판정한다.
- 기계 검증이 불가능한 조사·인터뷰·외부 승인 Task만 Acceptance: - 를 허용하고,
  DoD에는 사람이 확인할 산출물 위치나 승인 기록을 남긴다.

# 나쁜 예시
DoD: 코드가 잘 작성됨
Acceptance: true
Acceptance: pytest tests || echo skip
Acceptance: test -f ../other-repo/Plans.md
```

**`.claude/agent-memory/*/MEMORY.md`**
세 파일 모두 아래 섹션을 찾아서 채운다:

```markdown
## Project Context

프로젝트: [실제 프로젝트 이름]
목표: [핵심 목표 한 줄]
```

### Step 3 — harness 동기화

```bash
harness sync    # harness.toml → .claude-plugin/ 파일 생성
harness doctor  # 전체 통과 확인
```

### Step 4 — GitHub 연동 (선택)

```toml
# harness.toml
[github]
enabled = true
```

```bash
gh auth login
harness sync
```

`.github/workflows/ci.yml`에서 기술 스택 블록 주석 해제 후 branch protection 설정.
→ 상세: [docs/github-integration.md](./docs/github-integration.md)

---

## 기존 프로젝트에 적용

이미 코드·README·문서가 있는 프로젝트에 이 harness만 얹는 경우. `init.sh`는
빈 프로젝트를 가정하고 전체 세트를 복사하므로, 기존 파일과 겹치는 항목은
개별로 골라 복사한다.

1. 기존 프로젝트 루트로 이동한다.
2. 다음만 개별 복사한다 (전체 `init.sh` 실행 금지 — 기존 README·docs를 덮어쓸 수 있다):
   ```bash
   cp /tmp/harness-tpl/harness.toml .
   cp /tmp/harness-tpl/CLAUDE.md .
   cp /tmp/harness-tpl/AGENTS.md .
   cp -r /tmp/harness-tpl/agents .
   cp -r /tmp/harness-tpl/templates/skeleton/.harness .
   cp /tmp/harness-tpl/templates/skeleton/Plans.md .
   cp -r /tmp/harness-tpl/templates/skeleton/tasks .
   cp -r /tmp/harness-tpl/scripts .
   mkdir -p .claude/agent-memory
   cp -r /tmp/harness-tpl/.claude/agent-memory/. .claude/agent-memory/
   ```
3. `CLAUDE.md`가 기존 `README.md`/아키텍처 문서를 대체하지 않게, `CLAUDE.md`
   안에서 그 문서들을 참조하도록 링크만 추가한다. `docs/templates/*` 골격은
   그런 문서가 아예 없을 때만 복사한다.
4. `tasks/index.json`에 "기존 코드 파악" Week 0 Task를 추가한다 — DoD·Acceptance를
   명시해 [세분화 게이트](#구현-규칙-세분화-게이트)를 통과하게 쓰고,
   `python3 scripts/sync_plans.py`로 `Plans.md`를 갱신한다.
5. `.claude/agent-memory/*/MEMORY.md`의 `Project Context`를 채운다.
6. `harness sync && harness doctor`.
7. 첫 작업 전에 Claude Code에게 규칙 요약과 빈틈 점검을 요청한다:

```text
Read CLAUDE.md.
Check whether this existing project already has architecture docs, tests,
and verification commands (build/test/lint scripts).
If anything is missing, propose the minimum harness files needed before
implementation — do not create files speculatively.
```

```text
CLAUDE.md를 읽어줘.
이 기존 프로젝트에 아키텍처 문서, 테스트, 검증 명령(빌드/테스트/린트)이
이미 있는지 확인해줘.
빠진 게 있으면 구현 전에 필요한 최소한의 harness 파일만 제안해줘 — 임의로
먼저 만들지는 마.
```

---

## Recommended Codex Workflow

Codex에서는 루트 `AGENTS.md`가 진입점이고, `.agents/skills/`의 repo-scoped
skills가 Claude Code workflow에 대응한다. top-level `/harness-work` slash
command를 만들지 않고, `/skills`에서 선택하거나 `$harness-work`처럼 명시 호출한다.

```text
AGENTS.md를 읽어줘.
/skills 목록에서 harness skill을 확인해줘.
$harness-progress로 현재 상태를 요약해줘.
```

핵심 매핑:

| Claude Code | Codex |
|---|---|
| `/grill-me` | `$grill-me` |
| `/harness-plan` | `$harness-plan` |
| `/harness-work` | `$harness-work` |
| `/harness-review` | `$harness-review` |
| `/harness-progress` | `$harness-progress` |
| `/harness-sync` | `$harness-sync` |
| `/branch-checkout` | `$branch-checkout` |
| `/git-push` | `$git-push` |
| `/pr-create` | `$pr-create` |
| `/rescue-from-main` | `$rescue-from-main` |

---

## Recommended Claude Code Workflow

```bash
# 1. Claude Code 열기
claude

# 2. (새 프로젝트/기능이면) 기획 — 인터뷰로 PRD 작성
/grill-me
#    → docs/PRD.md 초안 → UserFlow·Architecture 보완 (docs/templates/ 골격)

# 3. 할 일 추가 (planning context → task-decomposer proposal → 검증 → tasks/index.json 반영)
/harness-plan

# 4. 실행 (세분화 + quality gate 통과 확인 → worker → reviewer → advisor 자동 순환)
/harness-work

# 5. 진행 상황 확인
/harness-progress

# 6. tasks/index.json ↔ 구현 상태 확인 (필요 시 Plans.md snapshot 갱신)
/harness-sync
```

### `/harness-work` 내부 흐름

1. `tasks/index.json`에서 `todo` 상태 Task를 선택
1-a. **세분화 + quality gate**: 선택된 Task가 `agents/task-decomposer.md` 기준(1 PR 이내·
   단일 관심사·DoD/Acceptance 명시) 또는 `agents/quality-gates.md`의 scope/YAGNI
   기준을 못 채우면 worker에게 넘기지 않고 task-decomposer를 다시 실행해 하위
   Task로 쪼갠 뒤에만 진행
2. **advisor**에게 방향 물어봄 (VFF v2 전체 적용 — 핵심 변수 먼저, 일반론 금지)
3. **worker**에게 구현 위임 (ponytail 7단계 + VFF 검증 의무 + quality gate) —
   진행 중 범위 초과를 발견하면 즉시 멈추고 task-decomposer를 재호출해 하위
   Task로 분리
4. **test-agent**가 런타임 검증 — Acceptance 명령 + 프로젝트 테스트 스위트 실행.
   FAIL 시 worker에 재위임, PASS 시에만 다음 단계 진행
5. **reviewer**에게 검토 요청 (VFF v2 전체 + quality gate — findings와 검증 근거 먼저)
6. 완료 반영: Acceptance와 관련 테스트가 통과하면 세션이
   `tasks/index.json`의 대상 Task를 `done`으로 갱신하고
   `python3 scripts/sync_plans.py`를 실행한다. GitHub Actions는 Task 상태를
   바꾸지 않는다.

> **동작 원리 주의**: 위 흐름 중 task-decomposer/quality gate(1-a)와 test-agent 실행(4),
> GitHub Issue/PR 자동화는 harness 플러그인 내장 기능이 아니라 **CLAUDE.md의 지시를
> Claude가 세션에서 직접 수행**하는 규약이다. `harness.toml`의
> `[github]`·`[review]`·`[test]`·`[plan]` 섹션은 `harness sync`가 파싱하지 않으며
> 규약의 SSOT 요약 인덱스 역할만 한다. `plans-guard.yml`은 Task manifest와
> `Plans.md` snapshot이 유효한지만 확인한다. 세분화·scope/YAGNI·Acceptance 실행은
> 세션 에이전트의 책임이다. 상세: [BLUEPRINT.md](./BLUEPRINT.md).

### `/harness-plan` 감시 로그

`/harness-plan`은 확정 Task를 바로 쓰지 않고 `.harness/shared/planning/runs/{run_id}/`
아래에 `context.json`, `proposed-tasks.json`, `decomposition-report.md`를 먼저 만든다.
검증을 통과한 proposal만 `tasks/index.json`에 반영된다.

planning 진행 상황은 `.harness/events/planning.jsonl`에 JSONL로 누적된다. 각 줄의
최상위 필드는 개발자가 아닌 사용자도 이해할 수 있는 `step`, `result`, `message`,
`next_action`이며, 도구용 값은 `technical` 하위에만 둔다.

v1 범위는 planning 단계뿐이다. `work.jsonl`, `review.jsonl`, SQLite, 모든 대화 턴
기록은 만들지 않는다.

---

## Claude Code Commands

이 저장소엔 로컬 slash command 디렉토리(`.claude/commands/`)가 없다.
`/harness-*` 계열은 설치한 **claude-code-harness 플러그인**이 제공하고,
`/grill-me`만 이 저장소의 로컬 스킬(`.claude/skills/grill-me/SKILL.md`)이다.

| 명령어 | 출처 | 동작 |
|--------|------|------|
| `/grill-me` | 로컬 스킬 (이 저장소) | 인터뷰 기반 PRD 작성 (기획 단계 진입점) |
| `/harness-plan` | claude-code-harness 플러그인 | planning context/proposal 생성 → 검증 통과 Task를 tasks/index.json에 반영 + Plans.md 갱신 |
| `/harness-work` | claude-code-harness 플러그인 | Task 실행 (worker 팀 가동) |
| `/harness-review` | claude-code-harness 플러그인 | 현재 코드·계획 리뷰 |
| `/harness-progress` | claude-code-harness 플러그인 | 진행 현황 대시보드 |
| `/harness-sync` | claude-code-harness 플러그인 | tasks/index.json ↔ Plans.md ↔ 구현 상태 동기화 확인 |
| `harness doctor` | claude-code-harness CLI | 설치 상태 전체 점검 |
| `harness sync` | claude-code-harness CLI | `harness.toml` 변경 후 적용 |
| `/caveman lite\|full\|ultra` | caveman 플러그인 | 응답 압축 강도 조절 |
| `/ponytail lite\|full\|ultra` | ponytail 플러그인 | lazy mode 강도 조절 |
| `/ponytail-review` | ponytail 플러그인 | 현재 diff 과잉 구현 리뷰 |
| `/itsvff` | value-for-fable 플러그인 | VFF 세션 모드 수동 활성화 |
| `/branch-checkout` | 로컬 custom command | 별도 작업 브랜치 생성·전환 |
| `/git-push` | 로컬 custom command | 현재 브랜치 안전 push |
| `/pr-create` | 로컬 custom command | 현재 브랜치에서 draft PR 작성 |
| `/rescue-from-main` | 로컬 custom command | main/master 변경사항을 작업 브랜치로 옮겨 draft PR 작성 |

Codex용 동등 절차는 `.agents/skills/` 아래 repo-scoped skills로 제공한다.
Codex에서는 ponytail/caveman plugin 자동 hook을 가정하지 않고
`agents/quality-gates.md`를 공통 기준으로 적용한다.

### Task 상태 값

| JSON 값 | Plans.md 표시 | 의미 |
|------|------|------|
| `todo` | `cc:TODO` | 미시작. harness가 선택 대상으로 봄 |
| `wip` | `cc:WIP` | 진행 중. task 브랜치 착수 시 세션이 설정 |
| `done` | `cc:완료` | 완료. Acceptance와 관련 테스트 통과 후 세션이 직접 갱신 |
| `blocked` | `cc:BLOCKED` | 차단됨. `blocked_reason` 필수 |

---

## Claude Code Hooks

이 템플릿엔 현재 hooks가 설정돼 있지 않다. `.claude/settings.local.json.example`은
권한(permissions) 예시일 뿐 hooks 항목은 비어 있다 — 아래는 추가 권장 사항이며
있는 것처럼 쓰지 않는다.

권장 hooks:

- 파일 수정 후 formatter/lint 실행
- 파일 수정 후 관련 테스트 실행
- 위험한 shell command(`rm -r`, `git push --force` 등) 실행 전 확인 —
  `harness.toml`의 `[safety.permissions] ask` 목록과 역할이 겹치므로 중복 등록 주의
- 세션 종료 시 `.harness/tasks/<task-key>/STATE.md` 갱신 여부 확인
- Acceptance 명령 미실행 상태에서 Task를 `done`으로 표시하는 것 방지

hooks 설정 예시는 이 README에 넣지 않고 `docs/claude-code-hooks.md`로 분리할 것을
권장한다 (아래 [추가 권장 문서](#추가-권장-문서) 참고).

---

## Session Recovery

터미널 세션은 언제든 끊길 수 있다는 전제로 이 템플릿을 만들었다 (CLAUDE.md
상태 문서 규칙). 재개 시 읽는 순서는 고정돼 있다.

1. `tasks/index.json` — Task 상태 단일 출처 (`wip` Task 확인)
2. `.harness/tasks/<task-key>/STATE.md` — 해당 Task 현재 상태 스냅샷
3. `.harness/LESSONS.md` — 최근 항목 (전역 재발 방지 기록)
4. `Plans.md` — 사람이 읽는 snapshot. stale일 수 있으므로 상태 판단은 `tasks/index.json` 기준
5. 필요할 때만 `.harness/tasks/<task-key>/HANDOFF.md`, `TASKS.md`, `LOG.md`,
   `CHECKPOINTS.md` — `.harness/CONTEXT_INDEX.md`가 전체 인덱스다.

루트 `.harness/STATE.md`, `HANDOFF.md`, `TASKS.md`, `LOG.md`, `CHECKPOINTS.md`는
새 Task 디렉토리로 복사해서 쓰는 템플릿이다. 실제 작업 상태는
`.harness/tasks/<task-key>/` 아래에 남긴다.

재개 프롬프트:

```text
Read tasks/index.json to identify the wip or requested Task.
Then read .harness/tasks/<task-key>/STATE.md, recent .harness/LESSONS.md entries,
and Plans.md.
Resume from the last recorded state.
Do not repeat completed Tasks unless Acceptance requires re-verification.
Before continuing, summarize the current state and next action.
```

```text
tasks/index.json에서 wip 또는 지정된 Task를 확인한 뒤,
.harness/tasks/<task-key>/STATE.md와 .harness/LESSONS.md 최근 항목,
Plans.md를 읽어줘.
마지막으로 기록된 상태부터 작업을 재개해줘.
Acceptance 재검증이 필요한 경우가 아니면 이미 완료된 Task는 반복하지 마.
계속하기 전에 현재 상태와 다음 작업을 먼저 요약해줘.
```

---

## Error Memory / 반복 실패 방지

에러 기록은 Task별 `.harness/tasks/<task-key>/LOG.md`(append-only, 원문 그대로)와
전역 `.harness/LESSONS.md`(해결 후 재발 방지 요약)로 나뉜다 — 하나의 파일에 섞지 않는다.

- `.harness/tasks/<task-key>/LOG.md`: 시간 역순 아님, 위에서 아래로 추가만.
  실패한 명령·에러 메시지·조치를 있는 그대로 남긴다.
- `.harness/LESSONS.md`: 최신 항목이 위. "무엇이 문제였고, 다음엔 어떻게
  판단할지"를 근거와 함께 남긴다. 항상 지켜야 할 규칙으로 승격되면
  `CLAUDE.md`에도 반영한다.

기록 프롬프트:

```text
If an error occurs, log the raw command and error message in .harness/tasks/<task-key>/LOG.md.
Once fixed, summarize the cause and a prevention rule in .harness/LESSONS.md.
If it should always apply going forward, also update CLAUDE.md.
```

```text
에러가 발생하면 실패한 명령과 에러 메시지를 원문 그대로 .harness/tasks/<task-key>/LOG.md에 남겨줘.
해결되면 원인과 재발 방지 규칙을 .harness/LESSONS.md에 요약해줘.
항상 지켜야 할 규칙이면 CLAUDE.md에도 반영해줘.
```

---

## 파일 구조

```text
cc-harness-template/
│
├── harness.toml                    # 프로젝트 이름·안전 규칙·review·test 설정 (실행 SSOT는 CLAUDE.md — 요약 인덱스)
├── CLAUDE.md                       # Claude Code가 항상 읽는 프로젝트 규칙
├── AGENTS.md                       # Codex가 항상 읽는 프로젝트 규칙 진입점 (CLAUDE.md 규약 실행)
├── tasks/index.json                # Task 상태 단일 출처 (todo / wip / done / blocked)
├── Plans.md                        # 사람이 읽는 Task snapshot (필요할 때 tasks/index.json에서 생성)
├── BLUEPRINT.md                    # 이 시스템 전체 아키텍처 설명 (읽기용)
├── init.sh                         # 새 프로젝트에 이 템플릿 적용 (아래 전부를 자동 복사)
├── LICENSE                         # MIT
│
├── scripts/
│   ├── setup-plugins.sh            # ~/.claude/settings.json 플러그인 등록·설치 자동화
│   ├── merge-settings.mjs          # setup-plugins.sh가 호출하는 JSON 병합 로직 (Node)
│   ├── validate_tasks.py           # tasks/index.json 검증
│   ├── validate_task_proposal.py   # proposed-tasks.json 검증
│   ├── apply_task_proposal.py      # 검증된 proposal → tasks/index.json 반영 + Plans.md 갱신
│   ├── build_planning_context.py   # /harness-plan 입력 context.json 생성
│   ├── run_task_decomposer.py      # 외부 decomposer 명령 계약 실행 + planning.jsonl 기록
│   ├── planning_log.py             # planning.jsonl에 사용자 친화 이벤트 append
│   ├── report_tasks.py             # 진행률·WIP·다음 TODO 출력
│   └── sync_plans.py               # tasks/index.json → Plans.md snapshot 생성
│
├── agents/                         # 절차 문서 — task-decomposer는 planning proposal 계약, test-agent는 세션 검증 절차
│   ├── task-decomposer.md          # 계획 세분화 + 구현 게이트 정의 (harness.toml [plan])
│   └── test-agent.md               # test-agent 정의 (Acceptance 실행 + 테스트 스위트)
│
├── .agents/
│   └── skills/                     # Codex repo-scoped skills
│       ├── branch-checkout/SKILL.md
│       ├── git-push/SKILL.md
│       ├── grill-me/SKILL.md
│       ├── harness-plan/SKILL.md
│       ├── harness-work/SKILL.md
│       ├── harness-review/SKILL.md
│       ├── harness-progress/SKILL.md
│       ├── harness-sync/SKILL.md
│       ├── pr-create/SKILL.md
│       └── rescue-from-main/SKILL.md
│
├── templates/skeleton/             # init.sh가 복사하는 tasks/·Plans.md·.harness/ 템플릿 구조 (dogfood 이력 없음)
│   ├── Plans.md
│   ├── tasks/index.json
│   └── .harness/                   # 루트 템플릿 + tasks/.gitkeep
│
├── .harness/                       # Task별 세션 맥락 템플릿과 전역 기록
│   ├── STATE.md / HANDOFF.md / TASKS.md / LOG.md / CHECKPOINTS.md  # 복사용 템플릿
│   ├── LESSONS.md                  # 전역 재발 방지 기록
│   ├── CONTEXT_INDEX.md            # 파일 역할 인덱스 — 세션 재개 시 필요한 파일만 선별
│   ├── tasks/<task-key>/           # 실제 Task별 상태·로그·인수인계·checkpoint
│   ├── shared/planning/runs/        # /harness-plan run별 context/proposal/report 작업대
│   └── events/planning.jsonl        # planning 단계 감시 로그 (JSONL, v1 범위)
│
├── .github/                        # GitHub 연동 시 사용 (harness.toml enabled = true)
│   ├── workflows/
│   │   ├── ci.yml                  # 빌드·테스트 CI + ci-ok 요약 잡(required check 이름 고정용)
│   │   └── plans-guard.yml         # PR 시 tasks/index.json 검증 + Plans.md sync 확인
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│
├── .claude/
│   ├── settings.local.json.example # 프로젝트 전용 권한 설정 (복사 후 rename)
│   ├── commands/                   # Claude Code local custom commands
│   │   ├── branch-checkout.md
│   │   ├── git-push.md
│   │   ├── pr-create.md
│   │   └── rescue-from-main.md
│   ├── skills/
│   │   └── grill-me/SKILL.md       # 인터뷰 기반 PRD 작성 스킬 (기획 단계 진입점)
│   └── agent-memory/
│       ├── claude-code-harness-worker/MEMORY.md    # worker 행동 규칙
│       ├── claude-code-harness-reviewer/MEMORY.md  # reviewer 행동 규칙
│       └── claude-code-harness-advisor/MEMORY.md   # advisor 행동 규칙
│
└── docs/
    ├── templates/                  # 기획 산출물 골격 (PRD·UserFlow·DESIGN·Architecture)
    ├── specs/                      # 이 템플릿 자체의 감사·설계 기록 (온보딩 자료 아님)
    ├── setup-guide.md              # 상세 설치 가이드
    ├── github-integration.md       # GitHub 연동 상세 가이드
    └── global-settings-reference.md  # ~/.claude/settings.json 레퍼런스
```

> **MEMORY.md가 하는 일**: harness가 에이전트를 실행할 때 이 파일을 읽어서
> "이 에이전트는 caveman lite로 응답해라", "VFF v2 전체를 적용해라"처럼 행동 규칙을
> 주입한다. `.claude/agent-memory/` 경로가 고정이므로 위치를 바꾸면 안 된다.

---

## Troubleshooting

### Claude Code가 `CLAUDE.md`를 따르지 않음

세션 시작 직후 `CLAUDE.md`를 실제로 읽었는지 첫 응답에서 확인한다. 안 읽었으면
[첫 프롬프트](#첫-프롬프트)를 다시 붙여넣는다.

### `CLAUDE.md`가 길어져 컨텍스트를 많이 차지함

실제로 이 템플릿을 dogfooding하는 동안 `CLAUDE.md`가 118줄, 이어서 123줄로
늘어나며 분할 권고 훅 경고가 반복 발생한 이력이 있다(과거 로그와 Task별
`.harness/tasks/*/LOG.md` 참고).
프로젝트 전역 규칙만 `CLAUDE.md`에 남기고, 세부 절차는 `docs/`나 `agents/`로 옮긴다.

### 검증 명령을 실행하지 않고 완료라고 말함

`harness.toml`의 `[test] auto_run`은 요약 인덱스일 뿐 실제 강제력은
`CLAUDE.md`의 테스트 규칙 + `agents/test-agent.md`에서 나온다. `CLAUDE.md`가
로드됐는지, `tasks/index.json` 해당 Task에 Acceptance가 명령어 형태로 적혀 있는지 먼저 확인한다.

### 같은 에러를 반복함

`.harness/LESSONS.md` 최근 5개를 프롬프트에서 명시적으로 읽게 했는지 확인한다
(위 [Error Memory](#error-memory--반복-실패-방지) 참고).

### 세션이 끊겨 작업 상태를 모름

[Session Recovery](#session-recovery)의 재개 프롬프트를 사용한다.

### `/harness-*` 명령이 안 보임

로컬 명령이 아니라 플러그인 제공 명령이다. `claude plugin install
claude-code-harness@claude-code-harness-marketplace` 재실행 후 `harness doctor`로 확인한다.

### Codex에서 `/harness-work`가 안 먹힘

Codex에서는 Claude Code slash command가 아니라 repo-scoped skill을 쓴다.
`/harness-work` 대신 `$harness-work`처럼 호출하고, 먼저 `AGENTS.md`를 읽게 한다.

### Codex가 ponytail/caveman처럼 동작하지 않음

Codex에는 Claude Code plugin hook이 자동 적용되지 않는다.
`agents/quality-gates.md`가 Codex용 공통 기준이므로 scope/YAGNI, findings-first 리뷰,
짧은 검증 중심 보고를 세션에서 직접 적용한다.

### hooks가 실행되지 않음

이 템플릿엔 애초에 hooks가 설정돼 있지 않다 — [Hooks](#claude-code-hooks) 섹션 참고,
추가 후 Claude Code를 재시작해야 훅이 로드된다.

### 기존 프로젝트에 적용했는데 구조가 안 맞음

`init.sh` 전체 실행은 빈 프로젝트 기준이다. [기존 프로젝트에 적용](#기존-프로젝트에-적용)의
개별 복사 절차를 따른다.

### `harness doctor`에서 특정 항목 실패

```bash
harness sync
harness doctor
```

sync 후 재확인. 여전히 실패하면 해당 plugin을 재설치.

### worker가 caveman full로 응답할 때 (lite여야 함)

`.claude/agent-memory/claude-code-harness-worker/MEMORY.md`에
`### caveman: lite 모드` 섹션이 있는지 확인. Claude Code를 재시작하면
MEMORY.md를 다시 로드한다.

### Task가 선택되지 않을 때

Task 상태가 `tasks/index.json`에서 `todo`인지 확인. `wip`는 이미 진행 중으로 간주되어 건너뜀.

---

## Philosophy

이 템플릿은 Claude Code를 더 똑똑하게 만드는 도구가 아니다.
Claude Code가 실수해도 프로젝트가 망가지지 않도록 작업 환경을 구조화하는 도구다.

과잉 구현은 ponytail이, 장황한 응답은 caveman이, 역할 혼선은 harness의
worker/reviewer/advisor 분리가, 상태 유실은 `.harness/`가 각각 담당한다 —
하나의 거대한 규칙이 아니라 문제별로 좁게 겨눈 조합이다.

---

## Contributing

- PR 전 `harness doctor` + 변경과 관련된 `tasks/index.json` Acceptance 명령을 실행한다.
- `CLAUDE.md`/`harness.toml`을 바꾸면 이유를 커밋 메시지나 `tasks/index.json`/Plans.md에 남긴다 —
  별도 ADR 파일은 만들지 않는다(결정이 쌓이면 그때 분리).
- 새 워크플로/명령을 추가하면 README와 `BLUEPRINT.md`를 함께 갱신한다 —
  문서 하나만 고치고 링크된 상세 가이드를 놓친 이력이 실제로 있었다
  (`.harness/LESSONS.md` 2026-07-04 항목).
- 재발 방지 규칙을 추가할 땐 실제 재현 사례를 `.harness/LESSONS.md`에 함께 기록한다.

---

## 심화 문서

| 문서 | 내용 |
|------|------|
| [BLUEPRINT.md](./BLUEPRINT.md) | Plugin 간 협력 관계, 세션 타임라인, 에이전트 매트릭스 전체 설명 |
| [docs/setup-guide.md](./docs/setup-guide.md) | 설치 상세 절차, OS별 경로, 재설치 방법 |
| [docs/github-integration.md](./docs/github-integration.md) | GitHub Issues·PR·검증 CI 연동 상세 가이드 |
| [docs/global-settings-reference.md](./docs/global-settings-reference.md) | `~/.claude/settings.json` 전체 항목 설명 |

## 추가 권장 문서

이 README에 다 담기엔 과한 항목들 — 필요해지면 아래로 분리한다.

| 문서 | 담을 내용 |
|------|-----------|
| `docs/claude-code-hooks.md` | hooks 설정 예시, `harness.toml [safety.permissions]`와의 역할 분담 |
| `docs/session-recovery.md` | `.harness/tasks/` 재개 절차 심화 (여러 프로젝트 동시 운영 시나리오 포함) |
| `docs/error-memory.md` | Task별 `LOG.md`와 전역 `LESSONS.md` 작성 규칙 + 실제 사례 모음 |

`why-claude-code-harness`·`how-this-template-works`류는 이미 `BLUEPRINT.md`가
겸하고 있어 별도로 분리하지 않는다 — 중복 문서를 만들지 않는다.

### `docs/specs/` — 내부 감사·설계 기록 (온보딩 자료 아님)

새 프로젝트 적용에는 필요 없는, 이 템플릿 자체의 개발 이력 문서.

| 문서 | 내용 |
|------|------|
| `docs/specs/2026-07-04-template-audit.md` | Week 3 감사에서 발견한 빈틈(H1~H5)과 개선 계획 |
| `docs/specs/2026-07-03-planning-pipeline-design.md` | 기획 단계 산출물 파이프라인(PRD→UserFlow→Architecture) 설계 결정 |

---

## Plugin 버전 (이 템플릿 작성 기준)

이 표는 기록일 뿐 설치를 고정하지 않는다 — `claude plugin install`은 항상
마켓플레이스의 최신 커밋을 받아온다(M8/2026-07-04 감사). 버전 태그가 없는
플러그인(caveman 등)은 SHA만 유일한 식별자이므로, 아래 SHA를 "마지막으로
정상 동작 확인한 시점"의 기준선으로 남긴다.

| Plugin | 버전 | 확인된 SHA | 확인일 | GitHub |
|--------|------|-----------|--------|--------|
| claude-code-harness | 4.16.4 | `c220671` | 2026-07-07 | [Chachamaru127/claude-code-harness](https://github.com/Chachamaru127/claude-code-harness) |
| ponytail | 4.8.4 | `1b2760d` | 2026-07-07 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| caveman | 25d22f8 | `0d95a81` | 2026-07-04 | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| value-for-fable | 1.0.1 | `afbfff6` | 2026-07-04 | [itsinseong/value-for-fable](https://github.com/itsinseong/value-for-fable) |

**업데이트 전 확인 절차** (마켓플레이스 업데이트는 전 프로젝트의 세션 동작을
한꺼번에 바꾼다 — 강제 버전 고정 기능은 플러그인 시스템 자체에 없으므로,
아래를 수동으로 지킨다):

1. 업데이트 전 각 저장소의 최근 커밋/changelog를 확인한다(`git log`, GitHub
   Releases, 또는 Compare 뷰로 현재 SHA ↔ 최신 커밋 diff 확인).
2. `/plugin` 메뉴 또는 마켓플레이스 클론에서 `git pull`로 갱신 후 Claude Code 재시작.
3. 이 템플릿이 의존하는 핵심 동작(세분화 게이트, caveman/ponytail 압축,
   VFF 리마인더 주입)이 여전히 기대대로 동작하는지 짧게 스팟 체크한다.
4. 문제 없으면 위 표의 "확인된 SHA"·"확인일"을 갱신한다.

---

## License

[MIT](./LICENSE) — Copyright (c) 2026 devRonPark
