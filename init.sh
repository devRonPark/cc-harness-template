#!/usr/bin/env bash
# init.sh — cc-harness-template을 새 프로젝트 디렉토리에 적용
#
# 사용법:
#   git clone https://github.com/devRonPark/cc-harness-template /tmp/harness-tpl
#   /tmp/harness-tpl/init.sh /path/to/my-new-project
#
# README.md "새 프로젝트에 적용" Step 1의 수동 cp 목록을 스크립트로 대체.
# 감사(H5/2026-07-04)에서 발견된 누락 항목(plans-complete.yml, ci.yml,
# .harness/ 골격, PR/Issue 템플릿)을 포함한 완전판 복사 목록을 사용한다.
# Plans.md·tasks/index.json·.harness/는 이 저장소 자신의 dogfood 이력이 아니라
# templates/skeleton/의 초기 상태 버전에서 복사한다.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:?사용법: init.sh /path/to/my-new-project}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "대상 디렉토리 없음: $TARGET_DIR" >&2
  exit 1
fi

echo "복사: $SRC_DIR → $TARGET_DIR"

mkdir -p "$TARGET_DIR"/{agents,scripts,tasks,.github/workflows,.github/ISSUE_TEMPLATE,.harness,docs/templates,.claude/commands,.claude/skills,.claude/agent-memory/claude-code-harness-worker,.claude/agent-memory/claude-code-harness-reviewer,.claude/agent-memory/claude-code-harness-advisor,.codex,.agents/skills}

# 최상위 설정
cp "$SRC_DIR/harness.toml" "$TARGET_DIR/"
cp "$SRC_DIR/CLAUDE.md" "$TARGET_DIR/"
cp "$SRC_DIR/AGENTS.md" "$TARGET_DIR/"
cp "$SRC_DIR/BLUEPRINT.md" "$TARGET_DIR/"

# Plans.md·tasks/index.json·.harness/ — dogfood 이력 없는 초기 상태 버전 (templates/skeleton/)
cp "$SRC_DIR/templates/skeleton/Plans.md" "$TARGET_DIR/Plans.md"
cp -r "$SRC_DIR/templates/skeleton/tasks/." "$TARGET_DIR/tasks/"
cp -r "$SRC_DIR/templates/skeleton/.harness/." "$TARGET_DIR/.harness/"

# Task 상태 관리 스크립트
cp "$SRC_DIR/scripts/tasklib.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/validate_tasks.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/report_tasks.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/sync_plans.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/build_planning_context.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/validate_task_proposal.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/apply_task_proposal.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/planning_log.py" "$TARGET_DIR/scripts/"
cp "$SRC_DIR/scripts/run_task_decomposer.py" "$TARGET_DIR/scripts/"

# companion 에이전트
cp -r "$SRC_DIR/agents/." "$TARGET_DIR/agents/"

# CI 워크플로 (plans-guard·plans-complete·ci 전부 — README 누락분 포함)
cp "$SRC_DIR/.github/workflows/plans-guard.yml" "$TARGET_DIR/.github/workflows/"
cp "$SRC_DIR/.github/workflows/plans-complete.yml" "$TARGET_DIR/.github/workflows/"
cp "$SRC_DIR/.github/workflows/ci.yml" "$TARGET_DIR/.github/workflows/"

# PR/Issue 템플릿
cp -r "$SRC_DIR/.github/ISSUE_TEMPLATE/." "$TARGET_DIR/.github/ISSUE_TEMPLATE/"
cp "$SRC_DIR/.github/PULL_REQUEST_TEMPLATE.md" "$TARGET_DIR/.github/"

# 에이전트 메모리
cp "$SRC_DIR/.claude/agent-memory/claude-code-harness-worker/MEMORY.md" \
   "$TARGET_DIR/.claude/agent-memory/claude-code-harness-worker/"
cp "$SRC_DIR/.claude/agent-memory/claude-code-harness-reviewer/MEMORY.md" \
   "$TARGET_DIR/.claude/agent-memory/claude-code-harness-reviewer/"
cp "$SRC_DIR/.claude/agent-memory/claude-code-harness-advisor/MEMORY.md" \
   "$TARGET_DIR/.claude/agent-memory/claude-code-harness-advisor/"
cp "$SRC_DIR/.claude/settings.local.json.example" "$TARGET_DIR/.claude/settings.local.json"

# 기획 스킬 + 산출물 골격 (grill-me → PRD·UserFlow·DESIGN·Architecture)
cp -r "$SRC_DIR/.claude/commands/." "$TARGET_DIR/.claude/commands/"
cp -r "$SRC_DIR/.claude/skills/grill-me" "$TARGET_DIR/.claude/skills/"
cp -r "$SRC_DIR/.agents/skills/." "$TARGET_DIR/.agents/skills/"
cp -r "$SRC_DIR/docs/templates/." "$TARGET_DIR/docs/templates/"

cat <<'EOF'

복사 완료. 다음 단계 (README.md "커스터마이징 체크리스트" 참고):
  1. harness.toml  — [project] name·description 실제 값으로 변경
  2. CLAUDE.md     — [PROJECT_NAME], 기술 스택, 디렉토리 구조, 코딩 규칙 채우기
     AGENTS.md     — Codex에서도 같은 규칙을 쓰도록 [PROJECT_NAME] 확인
     .agents/skills/ — Codex repo-scoped skill 노출 확인 (`/skills` 또는 `$harness-work`)
  3. tasks/index.json — Week 0 부트스트랩 Task부터 시작 (DoD/Acceptance 실제 값)
     python3 scripts/sync_plans.py 로 Plans.md 재생성
  4. .claude/agent-memory/*/MEMORY.md — Project Context 섹션 채우기
  5. cd 대상-디렉토리 && python3 scripts/validate_tasks.py && harness sync && harness doctor
EOF
