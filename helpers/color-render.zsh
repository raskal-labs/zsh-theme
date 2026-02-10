# ==============================================================================
# color-render.zsh
# Low-level colour rendering helpers (blocks, dithers, sample text)
# ==============================================================================

: "${ZCR_BLOCK:=█}"
: "${ZCR_DITHER_1:=▓}"
: "${ZCR_DITHER_2:=▒}"
: "${ZCR_DITHER_3:=░}"

_zcr_reset() {
  printf "\e[0m"
}

_zcr_fg_ansi() {
  printf "\e[38;5;%sm" "$1"
}

_zcr_fg_hex() {
  printf "\e[38;2;%d;%d;%dm" \
    $((16#${1[2,3]})) \
    $((16#${1[4,5]})) \
    $((16#${1[6,7]}))
}

_zcr_fg() {
  if [[ "$1" == \#* ]]; then
    _zcr_fg_hex "$1"
  else
    _zcr_fg_ansi "$1"
  fi
}

_zcr_blocks() {
  _zcr_fg "$1"
  printf "%s%s%s" "$ZCR_BLOCK" "$ZCR_BLOCK" "$ZCR_BLOCK"
  _zcr_reset
}

_zcr_dither() {
  _zcr_fg "$1"
  printf "%s%s%s" "$ZCR_DITHER_1" "$ZCR_DITHER_2" "$ZCR_DITHER_3"
  _zcr_reset
}

_zcr_sample_text() {
  printf " AaBb 1234 echo ./file.txt "
}
