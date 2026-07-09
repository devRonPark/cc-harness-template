# Setup Guide

새 프로젝트에는 수동 복사 대신 `init.sh`를 사용한다.

## Prerequisites

- Claude Code CLI
- Node.js 18+
- Python 3
- GitHub 연동 시 `gh` CLI

## Claude Plugin Setup

최초 1회:

```bash
git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
/tmp/harness-tpl/scripts/setup-plugins.sh --skip-vff
```

`setup-plugins.sh`는 `~/.claude/settings.json`을 백업한 뒤 required plugin만 병합한다.
`value-for-fable`을 쓰려면 `--with-vff`를 사용한다.

확인:

```bash
harness doctor
```

## Apply Template

```bash
/tmp/harness-tpl/init.sh /path/to/my-project
cd /path/to/my-project
python3 scripts/validate_tasks.py
python3 scripts/sync_plans.py --check
```

복사 후 채울 파일:

- `harness.toml`: `[project] name`, `description`
- `CLAUDE.md`: 프로젝트 개요, 기술 스택, 코딩 규칙
- `AGENTS.md`: Codex에서 추가로 필요한 예외가 있는지 확인
- `tasks/index.json`: 첫 Task, DoD, Acceptance
- `.claude/agent-memory/*/MEMORY.md`: Project Context

## GitHub Optional

GitHub 연동을 쓰는 경우:

```bash
gh auth login
git remote -v
```

1. `harness.toml [github].enabled = true`로 바꾼다.
2. `.github/workflows/ci.yml`의 `placeholder`를 실제 `check`/`test` job으로 교체한다.
3. `ci-ok`의 `needs`를 실제 job 목록으로 바꾼다.
4. Branch protection required check는 `ci-ok`, `plans-guard / tasks/index.json 검증`, `plans-guard / Plans.md sync 검증`을 등록한다.

상세 설정은 `docs/github-integration.md`를 본다.

## Daily Commands

| 목적 | Claude Code | Codex |
|---|---|---|
| 기획 | `/grill-me`, `/harness-plan` | `$grill-me`, `$harness-plan` |
| 구현 | `/harness-work` | `$harness-work` |
| 리뷰 | `/harness-review` | `$harness-review` |
| 진행 확인 | `/harness-progress`, `/harness-sync` | `$harness-progress`, `$harness-sync` |

Task 상태는 `tasks/index.json`이 단일 출처다. `Plans.md`는 `python3 scripts/sync_plans.py`로 생성한다.
