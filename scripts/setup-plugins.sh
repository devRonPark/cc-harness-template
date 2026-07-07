#!/usr/bin/env bash
# setup-plugins.sh — ~/.claude/settings.json에 이 템플릿이 요구하는 4개 plugin을
# 자동으로 등록하고 설치한다.
#
# 문제: README/setup-guide.md의 "Step 1"은 지금까지 사용자가 JSON 파일을 직접
# 열어 손으로 병합하는 방식이었다 — 콤마 하나만 틀려도 Claude Code 전체가
# 깨지고, 기존 설정을 실수로 덮어쓰기 쉽다. 이 스크립트는 그 단계를 대체한다.
#
# 사용법:
#   ./scripts/setup-plugins.sh
#
# 동작:
#   1. ~/.claude/settings.json이 없으면 새로 만들고, 있으면 기존 값을 보존한 채
#      enabledPlugins·extraKnownMarketplaces만 병합한다 (Node.js로 JSON 병합).
#   2. 수정 전 파일을 settings.json.bak.<timestamp>로 백업한다.
#   3. claude plugin install 4종을 실행한다.
#   4. harness doctor로 설치 상태를 확인한다.

set -euo pipefail

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS_FILE="$CONFIG_DIR/settings.json"

if ! command -v node >/dev/null 2>&1; then
  echo "오류: node가 필요하다 (Node.js 18+). 설치 후 다시 실행할 것." >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR"

if [ -f "$SETTINGS_FILE" ]; then
  BACKUP_FILE="$SETTINGS_FILE.bak.$(date +%Y%m%d%H%M%S)"
  cp "$SETTINGS_FILE" "$BACKUP_FILE"
  echo "기존 설정 백업: $BACKUP_FILE"
else
  echo "{}" > "$SETTINGS_FILE"
fi

node "$(dirname "${BASH_SOURCE[0]}")/merge-settings.mjs" "$SETTINGS_FILE"

echo ""
echo "settings.json 갱신 완료: $SETTINGS_FILE"
echo ""

if ! command -v claude >/dev/null 2>&1; then
  echo "경고: claude CLI를 찾을 수 없다 — plugin install을 건너뛴다." >&2
  echo "Claude Code 설치 후 아래를 직접 실행할 것:" >&2
  echo "  claude plugin install claude-code-harness@claude-code-harness-marketplace" >&2
  echo "  claude plugin install ponytail@ponytail" >&2
  echo "  claude plugin install caveman@caveman" >&2
  echo "  claude plugin install value-for-fable@itsinseong" >&2
  exit 0
fi

echo "Plugin 설치 중..."
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
claude plugin install value-for-fable@itsinseong

echo ""
if command -v harness >/dev/null 2>&1; then
  echo "설치 상태 확인 (harness doctor):"
  harness doctor
else
  echo "참고: harness CLI가 아직 없다. 설치 후 'harness doctor'로 확인할 것."
fi
