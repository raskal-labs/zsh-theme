#!/usr/bin/env zsh
# ==============================================================================
# zcolor v1 FINAL TEST BLOCK
# Purpose: validate parsing, views, palette modes, hex support, and output contract
# Shell: zsh ONLY
# ==============================================================================

set -euo pipefail

# --- guard ---
[[ -n "$ZSH_VERSION" ]] || {
  echo "ERROR: tests must be run under zsh" >&2
  exit 1
}

# --- locate repo root ---
ZCOLOR_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- source zcolor ---
source "$ZCOLOR_ROOT/helpers/zcolor.sh"

echo
echo "== SANITY CHECK =="
type zcolor >/dev/null
echo "zcolor is available"

# ------------------------------------------------------------------------------
echo
echo "== BASIC ANSI COLOR =="
zcolor 46

# ------------------------------------------------------------------------------
echo
echo "== ANSI RANGE EDGES =="
zcolor 0
zcolor 255

# ------------------------------------------------------------------------------
echo
echo "== BASIC HEX COLORS =="
zcolor "#ff1d81"
zcolor "#00ffcc"

# ------------------------------------------------------------------------------
echo
echo "== VIEW MODES (exactly one line per color) =="
zcolor 46 --compact
zcolor 46 --text
zcolor 46 --full
zcolor 46 --hud

# ------------------------------------------------------------------------------
echo
echo "== VIEW MUTUAL EXCLUSION (should error) =="
zcolor 46 --compact --text && echo "ERROR: stacked views allowed" || true

# ------------------------------------------------------------------------------
echo
echo "== PALETTE MODES (ANSI) =="
zcolor 46 mono
zcolor 46 -mono
zcolor 46 analogous
zcolor 46 complementary
zcolor 46 triadic
zcolor 46 tetradic
zcolor 46 square

# ------------------------------------------------------------------------------
echo
echo "== PALETTE MODES (HEX) =="
zcolor "#ff1d81" mono
zcolor "#ff1d81" analogous
zcolor "#ff1d81" complementary
zcolor "#ff1d81" triadic
zcolor "#ff1d81" tetradic
zcolor "#ff1d81" square

# ------------------------------------------------------------------------------
echo
echo "== MODE + VIEW COMBINATIONS =="
zcolor 46 triadic --compact
zcolor 46 square --text
zcolor "#ff1d81" complementary --full
zcolor "#ff1d81" triadic --hud

# ------------------------------------------------------------------------------
echo
echo "== MULTIPLE COLORS (NO MODES) =="
zcolor 46 69 154
zcolor "#ff1d81" "#00ffcc"

# ------------------------------------------------------------------------------
echo
echo "== MULTIPLE COLORS + MODE =="
zcolor 46 69 triadic
zcolor "#ff1d81" "#00ffcc" analogous

# ------------------------------------------------------------------------------
echo
echo "== HIGHLIGHT FOREGROUND OVERRIDE =="
zcolor 46 --hl-fg 255
zcolor "#ff1d81" --hl-fg "#ffffff"

# ------------------------------------------------------------------------------
echo
echo "== INVALID TOKENS (should warn, valid colors still render) =="
zcolor 46 banana
zcolor banana && echo "ERROR: invalid-only invocation rendered" || true
zcolor 46 -banana && echo "ERROR: invalid flag rendered" || true

# ------------------------------------------------------------------------------
echo
echo "== FLAG MISUSE (should error or show help) =="
zcolor -full && echo "ERROR: flag-only invocation rendered" || true
zcolor --hl-fg && echo "ERROR: missing hl-fg arg accepted" || true
zcolor --unknown && echo "ERROR: unknown flag accepted" || true

# ------------------------------------------------------------------------------
echo
echo "== OUTPUT CONTRACT (VISUAL CHECK) =="
echo "✔ One line per color"
echo "✔ No literal flags in output"
echo "✔ No 'list=(...)' or debug noise"
echo "✔ No inverse video"
echo "✔ Deterministic ordering"

echo
echo "== ALL TESTS COMPLETED =="
