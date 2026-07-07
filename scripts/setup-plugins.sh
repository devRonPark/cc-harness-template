#!/usr/bin/env bash
# setup-plugins.sh — ~/.claude/settings.json에 이 템플릿이 요구하는 plugin을
# 자동으로 등록하고 설치한다.
#
# 문제: README/setup-guide.md의 "Step 1"은 지금까지 사용자가 JSON 파일을 직접
# 열어 손으로 병합하는 방식이었다 — 콤마 하나만 틀려도 Claude Code 전체가
# 깨지고, 기존 설정을 실수로 덮어쓰기 쉽다. 이 스크립트는 그 단계를 대체한다.
#
# 사용법:
#   ./scripts/setup-plugins.sh [--skip-vff|--with-vff]
#
# value-for-fable은 optional plugin이다 (Sonnet에 Fable 5 진단 규율을 적용하는
# 개인 취향 플러그인). 필수 3종(claude-code-harness·ponytail·caveman)과 분리해
# 아래 순서로 포함 여부를 결정한다:
#   1. --skip-vff / --with-vff 플래그
#   2. SETUP_SKIP_VFF 환경변수 (1이면 스킵)
#   3. 위 둘 다 없고 대화형 터미널이면 y/N 프롬프트
#   4. 비대화형(CI 등)이고 위 셋 다 없으면 기존 동작 유지 차원에서 설치
#
# 동작:
#   1. ~/.claude/settings.json이 없으면 새로 만들고, 있으면 기존 값을 보존한 채
#      enabledPlugins·extraKnownMarketplaces만 병합한다 (Node.js로 JSON 병합).
#   2. 수정 전 파일을 settings.json.bak.<timestamp>로 백업한다.
#   3. claude plugin install로 필수 3종 + (선택 시) value-for-fable을 설치한다.
#   4. harness doctor로 설치 상태를 확인한다.

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
