# ==============================================================================
# hud-grid.zsh
# Constrained HUD / grid view for palette & color inspection
# ==============================================================================

: "${HUD_COLS:=28}"

_hud_cell() {
  local label="$1" color="$2"
  printf "%-10s " "$label"
  _zcr_blocks "$color"
  printf " "
  _zcr_dither "$color"
}

_hud_row() {
  local label="$1" color="$2"
  printf "| "
  _hud_cell "$label" "$color"
  printf "%*s|\n" $((HUD_COLS - 14)) ""
}

_hud_header() {
  printf "+-%*s-+\n" "$HUD_COLS" "" | tr ' ' '-'
}

_hud_palette_view() {
  echo
  _hud_header
  _hud_row "HOST"   "$PALETTE_PROMPT_HOST"
  _hud_row "PATH"   "$PALETTE_PROMPT_PATH"
  _hud_row "ANCHOR" "$PALETTE_PROMPT_ANCHOR"
  _hud_row "OK"     "$PALETTE_PROMPT_OK"
  _hud_row "ERR"    "$PALETTE_PROMPT_ERR"
  _hud_header
  echo
}

