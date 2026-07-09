# cc-harness-template

Claude Code와 Codex가 같은 repo 규칙으로 계획, 구현, 검증, 리뷰를 진행하게 하는 개인용 harness 템플릿.

최소 성공 흐름: 템플릿 적용 → `CLAUDE.md` 작성 → `tasks/index.json`에 작은 작업 작성 → 구현 → Acceptance/test 실행 → 실패는 `LOG.md`, 완료 요약은 `RUN_REPORT.md`에 기록.

## 먼저 고를 것

| 도구 | 시작점 | 명령 |
|---|---|---|
| Claude Code | `CLAUDE.md` | `/grill-me`, `/harness-plan`, `/harness-work` |
| Codex | `AGENTS.md` | `$grill-me`, `$harness-plan`, `$harness-work` |
| 둘 다 | `CLAUDE.md` 기준, `AGENTS.md` 호환 절차 | 같은 `tasks/index.json` 사용 |

Claude Code의 ponytail/caveman plugin hook은 Codex에서 자동 실행되지 않는다. Codex는 `AGENTS.md`, `.agents/skills/*`, `agents/quality-gates.md`를 직접 따른다.

## Quick Start

```bash
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
/tmp/harness-tpl/init.sh /path/to/my-project
cd /path/to/my-project
```

복사 직후 아래 파일을 먼저 채운다.

- `harness.toml`: `[project] name`, `description`
- `CLAUDE.md`: 프로젝트 개요, 기술 스택, 코딩 규칙
- `tasks/index.json`: 첫 작업, DoD, Acceptance 명령
- `.claude/agent-memory/*/MEMORY.md`: Claude Code agent용 Project Context

그다음:

```bash
python3 scripts/validate_tasks.py
python3 scripts/sync_plans.py
```

## Codex CLI Setup

Codex 세션 첫 프롬프트:

```text
AGENTS.md를 읽어줘.
tasks/index.json과 Plans.md 기준으로 현재 상태를 확인해줘.
$harness-progress로 진행 상황을 요약해줘.
```

Codex skill 매핑:

| 목적 | 호출 |
|---|---|
| 기획 인터뷰 | `$grill-me` |
| Task 추가 | `$harness-plan` |
| Task 구현 | `$harness-work` |
| 리뷰 | `$harness-review` |
| 진행 확인 | `$harness-progress` |
| Plans sync | `$harness-sync` |
| Harness YAGNI trim | `$harness-yagni-trimmer` |
| Git 작업 | `$branch-checkout`, `$git-push`, `$pr-create`, `$rescue-from-main` |

## Claude Code Setup

```bash
/tmp/harness-tpl/scripts/setup-plugins.sh --skip-vff
harness doctor
```

필수 plugin은 `claude-code-harness`, `ponytail`, `caveman`이다. `value-for-fable`은 선택이다.

Claude Code 세션 첫 프롬프트:

```text
먼저 CLAUDE.md를 읽어줘.
그다음 harness.toml, tasks/index.json, Plans.md, BLUEPRINT.md를 확인해줘.
구현 전 agents/quality-gates.md와 agents/task-decomposer.md를 적용해줘.
구현 후 tasks/index.json의 Acceptance 명령과 관련 테스트를 실행해줘.
```

## 작업별 Workflow

| 하고 싶은 일 | Claude Code | Codex | 완료 전 확인 |
|---|---|---|---|
| 새 기능 기획 | `/grill-me` | `$grill-me` | `docs/PRD.md` 또는 결정 기록 |
| Task 추가 | `/harness-plan` | `$harness-plan` | `validate_tasks.py`, `sync_plans.py --check` |
| Task 구현 | `/harness-work` | `$harness-work` | Acceptance/test 통과 |
| 현재 diff 리뷰 | `/harness-review` | `$harness-review` | blocker 없음 |
| 진행률 확인 | `/harness-progress` | `$harness-progress` | `tasks/index.json` 기준 |
| PR 준비 | `/git-push`, `/pr-create` | `$git-push`, `$pr-create` | 검증 evidence 포함 |

GitHub Actions는 Task 상태를 바꾸지 않는다. Acceptance와 관련 테스트가 통과하면 세션 에이전트가 `tasks/index.json`을 갱신하고 `python3 scripts/sync_plans.py`를 실행한다.

## 포함된 파일

핵심 파일은 `CLAUDE.md`, `AGENTS.md`, `harness.toml`, `tasks/index.json`, `Plans.md`, `agents/*`, `.harness/`, `.agents/skills/*`, `.claude/commands/*`, `.github/workflows/*`, `scripts/*`다.

상세 구조는 `BLUEPRINT.md`, 설치는 `docs/setup-guide.md`, GitHub 연동은 `docs/github-integration.md`를 본다.

## Session Recovery

재개 시 읽는 순서:

1. `tasks/index.json`
2. `.harness/tasks/<task-key>/STATE.md`
3. `.harness/tasks/<task-key>/RUN_REPORT.md`가 있으면 확인
4. `.harness/LESSONS.md` 최근 항목
5. `Plans.md`
6. 필요할 때만 `.harness/CONTEXT_INDEX.md`에서 추가 파일 선택

루트 `.harness/{STATE,HANDOFF,TASKS,LOG,CHECKPOINTS,RUN_REPORT}.md`는 템플릿이다. 실제 작업 상태는 `.harness/tasks/<task-key>/` 아래에 둔다.

## 기존 프로젝트에 적용

기존 README나 docs가 있으면 `init.sh` 전체 실행 대신 `harness.toml`, `CLAUDE.md`, `AGENTS.md`, `agents/`, `templates/skeleton/.harness`, `templates/skeleton/Plans.md`, `templates/skeleton/tasks`, `scripts/`만 골라 복사한다.

기존 문서가 있으면 `docs/templates/*`를 복사하지 말고 `CLAUDE.md`에서 기존 문서를 링크한다.

## Recommended Codex Workflow

Codex는 `AGENTS.md`를 읽힌 뒤 `$harness-progress`, `$harness-work` 순서로 진행한다. Claude Code는 `/grill-me`, `/harness-plan`, `/harness-work`, `/harness-progress`를 쓴다.

## Troubleshooting

- Claude Code가 규칙을 안 따르면 첫 응답에서 `CLAUDE.md`를 읽었는지 확인한다.
- Codex에서는 `/harness-work`가 아니라 `$harness-work`를 쓴다.
- Task가 선택되지 않으면 `tasks/index.json` 상태가 `todo`인지 확인한다.
- 완료라는데 검증이 없으면 해당 Task의 Acceptance 명령 실행 여부를 확인한다.
- 세션이 끊기면 Session Recovery 순서로 재개한다.
- GitHub check와 Task 상태가 다르면 `tasks/index.json`을 기준으로 본다.
- 같은 에러가 반복되면 `.harness/tasks/<task-key>/LOG.md`와 `.harness/LESSONS.md`를 확인한다.

## Plugin 버전 기록

설치는 최신 커밋을 받을 수 있으므로 아래 값은 고정이 아니라 마지막 확인 기준선이다. 업데이트 전 diff 확인 후 SHA와 확인일을 갱신한다.

기준선: claude-code-harness `c220671`, ponytail `1b2760d`, caveman `0d95a81`, value-for-fable `afbfff6`.

## License

[MIT](./LICENSE) — Copyright (c) 2026 devRonPark
