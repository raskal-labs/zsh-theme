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
  zpalette-preview.zsh \
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
          preview) _zpalette_preview "$@" ;;
          *) command zth palette "$sub" "$@" ;;
        esac
        ;;
      *)
        command zth "$cmd" "$@"
        ;;
    esac
  }
fi

# ------------------------------------------------------------------------------
# Public CLI commands
# ------------------------------------------------------------------------------

# Canonical palette command (parent for future subcommands)
zpalette() {
  local cmd="$1"
  (( $# )) && shift

  case "$cmd" in
    preview)
      _zpalette_preview "$@"
      ;;
    ""|-h|--help)
      echo "usage: zpalette preview <palette>"
      echo "       zpalette <command> [args]"
      ;;
    *)
      echo "zpalette: unknown command '$cmd'"
      return 1
      ;;
  esac
}

# Legacy / convenience aliases
alias zcolour='zcolor'
alias zpp='zpalette preview'
