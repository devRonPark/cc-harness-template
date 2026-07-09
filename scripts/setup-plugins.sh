#!/usr/bin/env bash
# setup-plugins.sh — required Claude plugins를 settings.json에 병합하고 설치한다.
# 사용법: ./scripts/setup-plugins.sh [--skip-vff|--with-vff]
# value-for-fable은 optional이다. 플래그, SETUP_SKIP_VFF, 대화형 prompt 순서로 결정한다.
# 기존 settings.json은 백업하고 enabledPlugins/extraKnownMarketplaces만 병합한다.

set -euo pipefail

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS_FILE="$CONFIG_DIR/settings.json"

INCLUDE_VFF=""
for arg in "$@"; do
  case "$arg" in
    --skip-vff) INCLUDE_VFF="0" ;;
    --with-vff) INCLUDE_VFF="1" ;;
  esac
done

if [ -z "$INCLUDE_VFF" ] && [ "${SETUP_SKIP_VFF:-}" = "1" ]; then
  INCLUDE_VFF="0"
fi

if [ -z "$INCLUDE_VFF" ]; then
  if [ -t 0 ]; then
    read -r -p "value-for-fable 플러그인도 설치할까요? (Sonnet에 Fable 5 진단 규율 적용, 개인 취향) [y/N] " REPLY
    case "$REPLY" in
      [yY]*) INCLUDE_VFF="1" ;;
      *) INCLUDE_VFF="0" ;;
    esac
  else
    INCLUDE_VFF="1"
  fi
fi

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

MERGE_ARGS=("$SETTINGS_FILE")
if [ "$INCLUDE_VFF" = "0" ]; then
  MERGE_ARGS+=(--skip-vff)
fi
node "$(dirname "${BASH_SOURCE[0]}")/merge-settings.mjs" "${MERGE_ARGS[@]}"

echo ""
echo "settings.json 갱신 완료: $SETTINGS_FILE"
if [ "$INCLUDE_VFF" = "0" ]; then
  echo "(value-for-fable은 건너뛴다 — 나중에 원하면 './scripts/setup-plugins.sh --with-vff'로 다시 실행)"
fi
echo ""

if ! command -v claude >/dev/null 2>&1; then
  echo "경고: claude CLI를 찾을 수 없다 — plugin install을 건너뛴다." >&2
  echo "Claude Code 설치 후 아래를 직접 실행할 것:" >&2
  echo "  claude plugin install claude-code-harness@claude-code-harness-marketplace" >&2
  echo "  claude plugin install ponytail@ponytail" >&2
  echo "  claude plugin install caveman@caveman" >&2
  if [ "$INCLUDE_VFF" = "1" ]; then
    echo "  claude plugin install value-for-fable@itsinseong" >&2
  fi
  exit 0
fi

echo "Plugin 설치 중..."
claude plugin install claude-code-harness@claude-code-harness-marketplace
claude plugin install ponytail@ponytail
claude plugin install caveman@caveman
if [ "$INCLUDE_VFF" = "1" ]; then
  claude plugin install value-for-fable@itsinseong
fi

echo ""
if command -v harness >/dev/null 2>&1; then
  echo "설치 상태 확인 (harness doctor):"
  harness doctor
else
  echo "참고: harness CLI가 아직 없다. 설치 후 'harness doctor'로 확인할 것."
fi
