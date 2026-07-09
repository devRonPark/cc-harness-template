# cc-harness-template

Claude Code와 Codex가 같은 repo 규칙으로 계획, 구현, 검증, 리뷰를 진행하게 하는 개인용 harness 템플릿.

최소 성공 흐름: 템플릿 적용 -> `CLAUDE.md` 작성 -> spec 정리 -> `tasks/index.json`에 작은 작업 작성 -> isolated work -> TDD -> fresh verification -> review -> finish. 실패는 `LOG.md`, 완료 요약과 evidence는 `RUN_REPORT.md`에 기록한다.

## Quick Start

```bash
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
/tmp/harness-tpl/init.sh /path/to/my-project
cd /path/to/my-project
python3 scripts/validate_tasks.py
python3 scripts/sync_plans.py --check
```

복사 직후 먼저 채울 파일: `harness.toml`, `CLAUDE.md`, `tasks/index.json`, `.claude/agent-memory/*/MEMORY.md`.

## 먼저 고를 것

| 도구 | 시작점 | 주요 호출 |
|---|---|---|
| Claude Code | `CLAUDE.md` | `/grill-me`, `/harness-plan`, `/harness-work` |
| Codex | `AGENTS.md` | `$grill-me`, `$harness-plan`, `$harness-work` |
| 둘 다 | `tasks/index.json` | 같은 Task 상태 사용 |

Claude Code의 ponytail/caveman plugin hook은 Codex에서 자동 실행되지 않는다. Codex는 `AGENTS.md`, `.agents/skills/*`, `agents/quality-gates.md`를 직접 따른다.

## Codex

```text
AGENTS.md를 읽어줘.
tasks/index.json과 Plans.md 기준으로 현재 상태를 확인해줘.
$harness-progress로 진행 상황을 요약해줘.
```

주요 skill: `$grill-me`, `$harness-plan`, `$harness-work`, `$harness-review`, `$harness-progress`, `$harness-sync`, `$harness-yagni-trimmer`, `$branch-checkout`, `$git-push`, `$pr-create`, `$rescue-from-main`.

## Claude Code

```bash
/tmp/harness-tpl/scripts/setup-plugins.sh --skip-vff
harness doctor
```

필수 plugin은 `claude-code-harness`, `ponytail`, `caveman`이다. `value-for-fable`은 선택이다.

```text
먼저 CLAUDE.md를 읽어줘.
그다음 harness.toml, tasks/index.json, Plans.md, BLUEPRINT.md를 확인해줘.
구현 전 agents/quality-gates.md와 agents/task-decomposer.md를 적용해줘.
구현 후 tasks/index.json의 Acceptance 명령과 관련 테스트를 실행해줘.
```

## Workflow

| 하고 싶은 일 | Claude Code | Codex | 완료 전 확인 |
|---|---|---|---|
| 새 기능 기획 | `/grill-me` | `$grill-me` | `docs/PRD.md` 또는 결정 기록 |
| Task 추가 | `/harness-plan` | `$harness-plan` | `validate_tasks.py`, `sync_plans.py --check` |
| Task 구현 | `/harness-work` | `$harness-work` | Acceptance/test 통과 |
| 현재 diff 리뷰 | `/harness-review` | `$harness-review` | blocker 없음 |
| 진행률 확인 | `/harness-progress` | `$harness-progress` | `tasks/index.json` 기준 |
| PR 준비 | `/git-push`, `/pr-create` | `$git-push`, `$pr-create` | TDD/fresh verification/review evidence 포함 |

GitHub Actions는 Task 상태를 바꾸지 않는다. Acceptance와 관련 테스트가 통과하면 세션 에이전트가 `tasks/index.json`을 갱신하고 `python3 scripts/sync_plans.py`를 실행한다.

TDD는 기능, 버그 수정, 동작 변경의 기본 완료 조건이다. 문서, 설정, 생성 코드, throwaway prototype은 예외로 둘 수 있지만 `RUN_REPORT.md`에 이유를 남긴다.

## Session Recovery

재개 시 읽는 순서:

1. `tasks/index.json`
2. `.harness/tasks/<task-key>/STATE.md`
3. `.harness/tasks/<task-key>/RUN_REPORT.md`가 있으면 확인
4. `.harness/LESSONS.md` 최근 항목
5. `Plans.md`
6. 필요할 때만 `.harness/CONTEXT_INDEX.md`에서 추가 파일 선택

루트 `.harness/{STATE,HANDOFF,TASKS,LOG,CHECKPOINTS,RUN_REPORT}.md`는 템플릿이다. 실제 작업 상태는 `.harness/tasks/<task-key>/` 아래에 둔다.

## 포함된 파일

핵심 파일은 `CLAUDE.md`, `AGENTS.md`, `harness.toml`, `tasks/index.json`, `Plans.md`, `agents/*`, `.harness/`, `.agents/skills/*`, `.claude/commands/*`, `.github/workflows/*`, `scripts/*`다.

상세 구조는 `BLUEPRINT.md`, 설치는 `docs/setup-guide.md`, GitHub 연동은 `docs/github-integration.md`를 본다.

## License

[MIT](./LICENSE) — Copyright (c) 2026 devRonPark
