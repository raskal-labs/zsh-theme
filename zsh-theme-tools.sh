#!/usr/bin/env zsh
# ==============================================================================
# zsh-theme-tools.sh
# Tool loader & command surface for zsh-theme
# ==============================================================================

# Resolve theme root reliably (sourcing-safe)
if [[ -z "$ZSH_THEME_ROOT" ]]; then
  ZSH_THEME_ROOT="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi

for helper in \
  util.zsh \
  color-render.zsh \
  zcolor.sh \
  palette-preview.zsh \
  hud-grid.zsh
do
  [[ -f "$ZSH_THEME_ROOT/helpers/$helper" ]] && \
    source "$ZSH_THEME_ROOT/helpers/$helper"
done

# --- extend zth (non-invasive) -----------------------------------------------

if typeset -f zth >/dev/null; then
  zth() {
    local cmd="${1:-status}"
    shift || true

    case "$cmd" in
      palette)
        local sub="${1:-preview}"
        shift || true
        case "$sub" in
          preview) _zth_palette_preview "$@" ;;
          *) command zth palette "$sub" "$@" ;;
        esac
        ;;
      *)
        command zth "$cmd" "$@"
        ;;
    esac
  }
fi
