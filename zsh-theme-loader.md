# >>> zsh-theme loader >>>
ZSH_THEME_DIR="$HOME/.config/prompt-palettes"
if [[ -f "$ZSH_THEME_DIR/current" ]]; then
  ZSH_THEME_NAME="$(head -n1 "$ZSH_THEME_DIR/current" | tr -d '\r\n')"
  if [[ -n "$ZSH_THEME_NAME" && -f "$ZSH_THEME_DIR/$ZSH_THEME_NAME.sh" ]]; then
    source "$ZSH_THEME_DIR/$ZSH_THEME_NAME.sh"
  fi
fi
# <<< zsh-theme loader <<<