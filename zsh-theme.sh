#!/usr/bin/env zsh
# ==============================================================================
# zth — Engine v2.9.1 (Clean Overwrite / Globbing Fix)
# ==============================================================================

: "${ZSH_THEME_ROOT:=$(cd "$(dirname "${(%):-%N}")" && pwd)}"
: "${ZSH_THEME_CONFIG:=${XDG_CONFIG_HOME:-$HOME/.config}/prompt-palettes}"
: "${ZSH_THEME_PALETTES:=$ZSH_THEME_ROOT/palettes}"

mkdir -p "$ZSH_THEME_CONFIG"
setopt INTERACTIVE_COMMENTS

_zth_apply_system() {
    # Tab Completion Aesthetics (Pink selection 199)
    zstyle ':completion:*' list-colors "ma=48;5:${PALETTE_SCOPE:-199};38;5;0"
    zstyle ':completion:*:default' list-colors "di=1;38;5;${PALETTE_DIR:-250}"
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${PALETTE_SUGGESTION:-244}"

    # High-Contrast Syntax Highlighting
    typeset -gA ZSH_HIGHLIGHT_STYLES 2>/dev/null || true
    ZSH_HIGHLIGHT_STYLES[command]="fg=${PALETTE_FG:-255},bold"
    ZSH_HIGHLIGHT_STYLES[path]="fg=${PALETTE_PATH:-51},bold"
    ZSH_HIGHLIGHT_STYLES[string]="fg=${PALETTE_STRING:-214}"
    ZSH_HIGHLIGHT_STYLES[constant]="fg=${PALETTE_CONST:-199}"
    ZSH_HIGHLIGHT_STYLES[comment]="fg=${PALETTE_SUGGESTION:-244},italic"

    # Structural Scaffolding & Grep Neon
export LS_COLORS="di=38;5;${PALETTE_DIR:-250}:fi=38;5;${PALETTE_FILE:-252}:ex=38;5;${PALETTE_SUCCESS:-82}:ln=38;5;${PALETTE_SCOPE:-199}"
    export GREP_COLORS="ms=38;5:${PALETTE_SCOPE:-199}"
    
    # Man Pages (HDR Gloss)
    export GROFF_NO_SGR=1
    export LESS_TERMCAP_md=$'\E[01;38;5;'"${PALETTE_SCOPE:-199}m"
    export LESS_TERMCAP_us=$'\E[04;38;5;'"${PALETTE_PATH:-51}m"
    export LESS_TERMCAP_so=$'\E[01;48;5;'"${PALETTE_ENV:-214};38;5;0m"
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'

    # Background & Aliases
    [[ "$PALETTE_BG" == "0" ]] && printf "\e]11;#000000\a"
    alias ls='ls --color=auto'
    alias la='ls -la --color=auto'

# Completion menu (semantic, palette-driven)
zstyle ':completion:*' list-colors \
  "di=38;5;${PALETTE_DIR:-250}" \
  "fi=38;5;${PALETTE_FILE:-252}" \
  "ex=38;5;${PALETTE_SUCCESS:-82}" \
  "ln=38;5;${PALETTE_SCOPE:-199}" \
  "ma=48;5;${PALETTE_SCOPE:-199};38;5;0"

zstyle ':completion:*:descriptions' format '%F{${PALETTE_SUGGESTION:-244}}%d%f'
zstyle ':completion:*:messages' format '%F{${PALETTE_ERROR:-196}}%d%f'
zstyle ':completion:*:warnings' format '%F{${PALETTE_ERROR:-196}}%d%f'
}

_zth_load_palette() {
    local target="${1:-$(cat $ZSH_THEME_CONFIG/current 2>/dev/null || echo electric)}"
    local p_file="$ZSH_THEME_PALETTES/$target.sh"
    if [[ -f "$p_file" ]]; then
        source "$p_file"
        echo "$target" > "$ZSH_THEME_CONFIG/current"
        _zth_apply_system
    fi
}

_zth_render() {
    local ret_status=${1:-$?}

    local host="${HOST%%.*}"
    local host_seg="%F{${PALETTE_PROMPT_HOST:-$PALETTE_ENV}}%B${host}%b%f"

    local glyph_color="${PALETTE_PROMPT_OK:-$PALETTE_SUCCESS}"
    [[ $ret_status -ne 0 ]] && glyph_color="${PALETTE_PROMPT_ERR:-$PALETTE_ERROR}"

    local zsh_path="${(%):-%~}"
    local anchor path_tail

    if [[ "$zsh_path" == "~"* ]]; then
        anchor="~"
        path_tail="${zsh_path[2,-1]}"
    elif [[ "$PWD" == /box* ]]; then
        anchor="/box"
        path_tail="${PWD#/box}"
    else
        anchor="/"
        path_tail="${zsh_path[2,-1]}"
    fi

local prompt_fg="${PALETTE_PROMPT_FG:-$PALETTE_FG}"
local prompt_anchor="${PALETTE_PROMPT_ANCHOR:-$PALETTE_SCOPE}"
local prompt_path="${PALETTE_PROMPT_PATH:-$PALETTE_PATH}"

echo "%F{${prompt_fg}}${host_seg} \
%F{${prompt_anchor}}%B${anchor}%b%f\
%F{${prompt_path}}${path_tail}%f \
%F{${glyph_color}}%B❯%b%f \
%{$reset_color%}"
}

_zth_hook() { PROMPT=$(_zth_render $?) }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _zth_hook

zth() {
    local cmd="${1:-status}"
    [[ $# -gt 0 ]] && shift 
    case "$cmd" in
        set) _zth_load_palette "$1" ;;
        status) print -P "Active: %B$(cat $ZSH_THEME_CONFIG/current)%b\n$(_zth_render 0)" ;;
        preview)
            local p_name="${1:-electric}"
            local p_file="$ZSH_THEME_PALETTES/$p_name.sh"
            if [[ -f "$p_file" ]]; then
                ( setopt INTERACTIVE_COMMENTS
                  source "$p_file"
                  echo -e "\n--- LIVE HDR PREVIEW: $p_name ---"
                  print -P "Success: $(_zth_render 0) %F{255}%Becho%b%f %F{214}'HDR'%f"
                  print -P "Error:   $(_zth_render 1) %F{255}%Bcat%b%f %F{196}missing.txt%f"
                  print -P "\n[Scaffolding]\nDir: %F{250}%Bscaffolding/%b%f  File: %F{252}data.txt%f" )
            else
                echo "Palette '$p_name' not found."
            fi
            ;;
    esac
}
_zth_load_palette

# Optional tooling (safe to skip in minimal environments)
[[ -f "$ZSH_THEME_ROOT/zsh-theme-tools.sh" ]] && \
    source "$ZSH_THEME_ROOT/zsh-theme-tools.sh"
