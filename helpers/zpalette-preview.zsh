# ==============================================================================
# zpalette-preview.zsh
# Descriptive palette inspection for zsh-theme
# ==============================================================================
[[ -n "$ZSH_VERSION" ]] || return 1
emulate -L zsh
setopt extendedglob

_zpalette_preview() {
  local name="${1:-$(cat "$ZSH_THEME_CONFIG/current" 2>/dev/null)}"
  local file="$ZSH_THEME_PALETTES/$name.sh"

  [[ ! -f "$file" ]] && {
    echo "Palette '$name' not found."
    return 1
  }

  (
    source "$file"

    echo
    echo "=== PALETTE PREVIEW: $name ==="
    echo

    local roles=(
      PROMPT_FG PROMPT_HOST PROMPT_ANCHOR PROMPT_PATH PROMPT_OK PROMPT_ERR
      FG ENV SCOPE PATH DIR FILE SUCCESS ERROR INPUT STRING CONST SUGGESTION
    )

    local role var color

    for role in "${roles[@]}"; do
      var="PALETTE_$role"
      color="${(P)var}"
      [[ -z "$color" ]] && continue

      printf "%-16s " "$role"
      _zc_render_line "$color" "full" ""
    done

    echo
  )
}

# Legacy compatibility
alias palette-preview=_zpalette_preview
