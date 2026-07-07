#!/usr/bin/env node
// merge-settings.mjs — settings.json에 이 템플릿이 요구하는 plugin 설정만
// 병합한다. 기존에 사용자가 넣어둔 다른 plugin·permissions·설정은 그대로 둔다.
// setup-plugins.sh가 백업본을 만든 뒤에 이 스크립트를 호출한다.
//
// value-for-fable은 optional plugin이다 — 세 번째 인자로 "--skip-vff"를
// 넘기면 enabledPlugins·extraKnownMarketplaces에서 제외한다.

import { readFileSync, writeFileSync } from "node:fs";

const target = process.argv[2];
if (!target) {
  console.error("사용법: node merge-settings.mjs <settings.json 경로> [--skip-vff]");
  process.exit(1);
}

const includeVff = process.argv[3] !== "--skip-vff";

const REQUIRED_PLUGINS = {
  "claude-code-harness@claude-code-harness-marketplace": true,
  "ponytail@ponytail": true,
  "caveman@caveman": true,
  ...(includeVff ? { "value-for-fable@itsinseong": true } : {}),
};

const REQUIRED_MARKETPLACES = {
  "claude-code-harness-marketplace": {
    source: { source: "github", repo: "Chachamaru127/claude-code-harness" },
  },
  ponytail: {
    source: { source: "github", repo: "DietrichGebert/ponytail" },
  },
  caveman: {
    source: { source: "github", repo: "JuliusBrussee/caveman" },
  },
  ...(includeVff
    ? {
        itsinseong: {
          source: { source: "git", url: "https://github.com/itsinseong/value-for-fable.git" },
        },
      }
    : {}),
};

let raw = "{}";
try {
  raw = readFileSync(target, "utf8");
} catch {
  // 파일이 없으면 빈 객체로 시작 — setup-plugins.sh가 이미 만들어두지만 방어적으로 처리
}

let settings;
try {
  settings = raw.trim() === "" ? {} : JSON.parse(raw);
} catch (err) {
  console.error(`오류: ${target}이(가) 올바른 JSON이 아니다 — 손상된 파일을 먼저 고칠 것.`);
  console.error(String(err.message));
  process.exit(1);
}

settings.enabledPlugins = { ...(settings.enabledPlugins ?? {}), ...REQUIRED_PLUGINS };
settings.extraKnownMarketplaces = {
  ...(settings.extraKnownMarketplaces ?? {}),
  ...REQUIRED_MARKETPLACES,
};

// 사용자가 이미 지정한 값은 존중하고, 없을 때만 권장 기본값을 채운다.
if (settings.tui === undefined) settings.tui = "fullscreen";
if (settings.theme === undefined) settings.theme = "dark";

writeFileSync(target, JSON.stringify(settings, null, 2) + "\n");
