# ==============================================================================
# palette-preview.zsh
# Palette inspection for zsh-theme
# ==============================================================================

_zth_color_dump() {
  local name="$1" color="$2"
  [[ -z "$color" ]] && return
  printf "%-22s %3s  " "$name" "$color"
  _zcr_blocks "$color"
  printf " "
  _zcr_dither "$color"
  printf "\n"
}

_zth_palette_preview() {
  local name="${1:-$(cat "$ZSH_THEME_CONFIG/current" 2>/dev/null)}"
  shift || true

  local view="blocks"
  local contrast=0
  local bg="auto"

  while [[ "$1" == --* ]]; do
    case "$1" in
      --view) view="$2"; shift ;;
      --contrast) contrast=1 ;;
      --bg) bg="$2"; shift ;;
    esac
    shift
  done

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

    for role in \
      PROMPT_FG PROMPT_HOST PROMPT_ANCHOR PROMPT_PATH PROMPT_OK PROMPT_ERR \
      FG ENV SCOPE PATH DIR FILE SUCCESS ERROR INPUT STRING CONST SUGGESTION
    do
      local var="PALETTE_$role"
      local color="${(P)var}"

      printf "%-22s " "$role"

      case "$view" in
        blocks) _zcr_blocks "$color" ;;
        dither) _zcr_dither "$color" ;;
        text)
          _zcr_fg "$color"; _zcr_sample_text; _zcr_reset ;;
        hud)
          _hud_palette_view
          return ;;
      esac

      (( contrast )) && _zc_contrast_hint "$color" "$bg"
      printf "\n"
    done

    echo
  )
}

