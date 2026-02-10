#!/usr/bin/env zsh
# ==============================================================================
# zcolor / zcolour — explicit color inspection & palette exploration
# v1 stabilization: hardened parse, single view, unified render, hex support,
# palette generation: mono/triadic/tetradic/square/analogous/complementary
# ==============================================================================

alias zcolour=zcolor

: "${ZCOLOR_BLOCK:=█}"
: "${ZCOLOR_D1:=▓}"
: "${ZCOLOR_D2:=▒}"
: "${ZCOLOR_D3:=░}"

_zc_reset() { printf "\e[0m"; }

_zc_sample_text() { printf "AaBb 123 ./file.txt"; }

# ------------------------------------------------------------------------------
# Color parsing + helpers
# ------------------------------------------------------------------------------

# Return 0 if token is ANSI int 0..255, else 1
_zc_is_ansi256() {
  [[ "$1" == <-> ]] || return 1
  (( $1 >= 0 && $1 <= 255 )) || return 1
  return 0
}

# Return 0 if token is #RRGGBB, else 1
_zc_is_hex() {
  emulate -L zsh
  setopt extendedglob
  [[ "$1" == (#i)\#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f] ]]
}

# Normalize hex to lowercase #rrggbb
_zc_norm_hex() {
  print -r -- "${1:l}"
}

# Convert #rrggbb -> "r g b" (0..255)
_zc_hex_to_rgb() {
  local h="${1#\#}"
  local r=$(( 16#${h[1,2]} ))
  local g=$(( 16#${h[3,4]} ))
  local b=$(( 16#${h[5,6]} ))
  print -r -- "$r $g $b"
}

# xterm-256 palette index -> "r g b"
# Deterministic mapping used widely for ANSI 256-color terminals.
_zc_ansi_to_rgb() {
  local c="$1"
  local -a base16=(
    "0 0 0"       "128 0 0"     "0 128 0"     "128 128 0"
    "0 0 128"     "128 0 128"   "0 128 128"   "192 192 192"
    "128 128 128" "255 0 0"     "0 255 0"     "255 255 0"
    "0 0 255"     "255 0 255"   "0 255 255"   "255 255 255"
  )
  if (( c < 16 )); then
    print -r -- ${=base16[$((c+1))]}
    return 0
  fi
  if (( c >= 16 && c <= 231 )); then
    local idx=$(( c - 16 ))
    local r=$(( idx / 36 ))
    local g=$(( (idx % 36) / 6 ))
    local b=$(( idx % 6 ))
    local -a steps=(0 95 135 175 215 255)
    print -r -- "${steps[$((r+1))]} ${steps[$((g+1))]} ${steps[$((b+1))]}"
    return 0
  fi
  # grayscale 232..255
  local v=$(( 8 + (c - 232) * 10 ))
  print -r -- "$v $v $v"
}

# "r g b" -> nearest xterm-256 index (approx, deterministic)
_zc_rgb_to_ansi() {
  local r="$1" g="$2" b="$3"

  # candidate 1: 6x6x6 cube
  local -a steps=(0 95 135 175 215 255)

  local nearest_step() {
    local x="$1"
    local best_i=1
    local best_d=999999
    local i v d
    for i in {1..6}; do
      v=${steps[$i]}
      d=$(( (x - v) * (x - v) ))
      (( d < best_d )) && { best_d=$d; best_i=$i; }
    done
    print -r -- "$best_i"
  }

  local ri gi bi
  ri="$(nearest_step "$r")"
  gi="$(nearest_step "$g")"
  bi="$(nearest_step "$b")"
  local cr=${steps[$ri]} cg=${steps[$gi]} cb=${steps[$bi]}
  local cube_idx=$(( 16 + (ri-1)*36 + (gi-1)*6 + (bi-1) ))
  local cube_dist=$(( (r-cr)*(r-cr) + (g-cg)*(g-cg) + (b-cb)*(b-cb) ))

  # candidate 2: grayscale ramp
  local gray_i=$(( ( (r + g + b) / 3 - 8 + 5 ) / 10 ))
  (( gray_i < 0 )) && gray_i=0
  (( gray_i > 23 )) && gray_i=23
  local gv=$(( 8 + gray_i * 10 ))
  local gray_idx=$(( 232 + gray_i ))
  local gray_dist=$(( (r-gv)*(r-gv) + (g-gv)*(g-gv) + (b-gv)*(b-gv) ))

  if (( gray_dist < cube_dist )); then
    print -r -- "$gray_idx"
  else
    print -r -- "$cube_idx"
  fi
}

# RGB -> HSL, HSL -> RGB (integer math kept simple; deterministic)
# These are not “color science”; they are standard HSL rotation tools.
_zc_rgb_to_hsl() {
  local r="$1" g="$2" b="$3"
  local rf=$(( r * 1000 / 255 ))
  local gf=$(( g * 1000 / 255 ))
  local bf=$(( b * 1000 / 255 ))

  local max=$rf min=$rf
  (( gf > max )) && max=$gf
  (( bf > max )) && max=$bf
  (( gf < min )) && min=$gf
  (( bf < min )) && min=$bf

  local l=$(( (max + min) / 2 ))   # 0..1000
  local d=$(( max - min ))

  local h=0 s=0
  if (( d == 0 )); then
    h=0; s=0
  else
    if (( l < 500 )); then
      s=$(( d * 1000 / (max + min) ))
    else
      s=$(( d * 1000 / (2000 - max - min) ))
    fi

    local hd=0
    if (( max == rf )); then
      hd=$(( ( (gf - bf) * 1000 ) / d ))
    elif (( max == gf )); then
      hd=$(( 2000 + ( (bf - rf) * 1000 ) / d ))
    else
      hd=$(( 4000 + ( (rf - gf) * 1000 ) / d ))
    fi
    # hd is in “sextants*1000”; convert to degrees 0..359
    local deg=$(( (hd * 60) / 1000 ))
    (( deg < 0 )) && deg=$(( deg + 360 ))
    h=$(( deg % 360 ))
  fi

  # output: h(0..359) s(0..1000) l(0..1000)
  print -r -- "$h $s $l"
}

_zc_hsl_to_rgb() {
  local h="$1" s="$2" l="$3" # h 0..359, s/l 0..1000

  if (( s == 0 )); then
    local v=$(( l * 255 / 1000 ))
    print -r -- "$v $v $v"
    return 0
  fi

  local q
  if (( l < 500 )); then
    q=$(( l * (1000 + s) / 1000 ))
  else
    q=$(( l + s - (l * s / 1000) ))
  fi
  local p=$(( 2 * l - q ))

  local hue2rgb() {
    local p="$1" q="$2" t="$3" # p/q in 0..1000, t in degrees
    (( t < 0 )) && t=$(( t + 360 ))
    (( t >= 360 )) && t=$(( t - 360 ))

    local res
    if (( t < 60 )); then
      res=$(( p + (q - p) * t / 60 ))
    elif (( t < 180 )); then
      res=$q
    elif (( t < 240 )); then
      res=$(( p + (q - p) * (240 - t) / 60 ))
    else
      res=$p
    fi
    print -r -- "$res"
  }

  local r1000 g1000 b1000
  r1000="$(hue2rgb "$p" "$q" $(( h + 120 )))"
  g1000="$(hue2rgb "$p" "$q" "$h")"
  b1000="$(hue2rgb "$p" "$q" $(( h - 120 )))"

  local r=$(( r1000 * 255 / 1000 ))
  local g=$(( g1000 * 255 / 1000 ))
  local b=$(( b1000 * 255 / 1000 ))
  print -r -- "$r $g $b"
}

# Given a color token (ansi int or hex), rotate hue by degrees; return same token type:
# - hex in -> hex out
# - ansi in -> ansi out (approx via RGB->HSL->RGB->nearest ansi)
_zc_rotate_hue() {
  local token="$1" deg="$2"

  if _zc_is_hex "$token"; then
    local rgb hsl r g b h s l nr ng nb
    rgb=($(_zc_hex_to_rgb "$(_zc_norm_hex "$token")"))
    hsl=($(_zc_rgb_to_hsl $rgb))
    h=$(( (hsl[1] + deg + 360) % 360 )); s=${hsl[2]}; l=${hsl[3]}
    rgb=($(_zc_hsl_to_rgb "$h" "$s" "$l"))
    printf "#%02x%02x%02x" $rgb
    return 0
  fi

  if _zc_is_ansi256 "$token"; then
    local rgb hsl r g b h s l
    rgb=($(_zc_ansi_to_rgb "$token"))
    hsl=($(_zc_rgb_to_hsl $rgb))
    h=$(( (hsl[1] + deg + 360) % 360 )); s=${hsl[2]}; l=${hsl[3]}
    rgb=($(_zc_hsl_to_rgb "$h" "$s" "$l"))
    _zc_rgb_to_ansi $rgb
    return 0
  fi

  return 1
}

# ------------------------------------------------------------------------------
# ANSI / HEX render primitives
# ------------------------------------------------------------------------------

_zc_fg() {
  local t="$1"
  if _zc_is_hex "$t"; then
    local rgb=($(_zc_hex_to_rgb "$(_zc_norm_hex "$t")"))
    printf "\e[38;2;%s;%s;%sm" "$rgb[1]" "$rgb[2]" "$rgb[3]"
  else
    printf "\e[38;5;%sm" "$t"
  fi
}

_zc_bg() {
  local t="$1"
  if _zc_is_hex "$t"; then
    local rgb=($(_zc_hex_to_rgb "$(_zc_norm_hex "$t")"))
    printf "\e[48;2;%s;%s;%sm" "$rgb[1]" "$rgb[2]" "$rgb[3]"
  else
    printf "\e[48;5;%sm" "$t"
  fi
}

# ------------------------------------------------------------------------------
# Render segments (explicit, never inverse)
# ------------------------------------------------------------------------------

_zc_render_blocks() { _zc_fg "$1"; printf "%s%s" "$ZCOLOR_BLOCK" "$ZCOLOR_BLOCK"; _zc_reset; }
_zc_render_dither() { _zc_fg "$1"; printf "%s%s%s" "$ZCOLOR_D1" "$ZCOLOR_D2" "$ZCOLOR_D3"; _zc_reset; }
_zc_render_text()   { _zc_fg "$1"; _zc_sample_text; _zc_reset; }

# Highlight with optional fg override
# If fg override is empty, use black (0 / #000000) by token type.
_zc_render_highlight() {
  local bg="$1" fg_override="$2"
  local fg
  if [[ -n "$fg_override" ]]; then
    fg="$fg_override"
  else
    if _zc_is_hex "$bg"; then
      fg="#000000"
    else
      fg=0
    fi
  fi
  _zc_bg "$bg"
  _zc_fg "$fg"
  _zc_sample_text
  _zc_reset
}

# ------------------------------------------------------------------------------
# Palette generators (deterministic; “correct” for hex; ANSI is approximation)
# ------------------------------------------------------------------------------

_zc_palette() {
  local base="$1" mode="$2"

  case "$mode" in
    "" )
      print -r -- "$base"
      ;;
    mono|monochrome )
      # for stability, keep your original “index-ish” feel but do it as small hue nudges:
      # -10°, 0°, +10° (works for hex; ok approx for ansi)
      print -r -- "$(_zc_rotate_hue "$base" -10) $base $(_zc_rotate_hue "$base" 10)"
      ;;
    analogous )
      # classic analogous: -30°, 0°, +30°
      print -r -- "$(_zc_rotate_hue "$base" -30) $base $(_zc_rotate_hue "$base" 30)"
      ;;
    complementary )
      # complement: 180°
      print -r -- "$base $(_zc_rotate_hue "$base" 180)"
      ;;
    triadic )
      # triad: 0°, +120°, +240°
      print -r -- "$base $(_zc_rotate_hue "$base" 120) $(_zc_rotate_hue "$base" 240)"
      ;;
    tetradic )
      # tetradic (rectangle): 0°, +60°, +180°, +240°
      # This is one common tetrad definition; deterministic and documented.
      print -r -- "$base $(_zc_rotate_hue "$base" 60) $(_zc_rotate_hue "$base" 180) $(_zc_rotate_hue "$base" 240)"
      ;;
    square )
      # square: 0°, +90°, +180°, +270°
      print -r -- "$base $(_zc_rotate_hue "$base" 90) $(_zc_rotate_hue "$base" 180) $(_zc_rotate_hue "$base" 270)"
      ;;
    * )
      # unknown mode -> treat as no mode
      print -u2 "zcolor: unknown mode '$mode'"
      return 1
      ;;
  esac
}

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

_zc_help() {
cat <<'EOF'
zcolor / zcolour — color inspection tool (v1)

USAGE:
  zcolor <color> [color...]
  zcolor <color> <mode> [view]
  zcolor <color> -<mode> [view]

COLORS:
  ANSI  : 0..255
  HEX   : #RRGGBB

MODES:
  mono | monochrome
  analogous
  complementary
  triadic
  tetradic
  square

VIEWS (choose exactly one; default: --full):
  --full        blocks + dither + text + highlight
  --compact     blocks + dither
  --text        text only
  --hud         blocks + dither + text (one-line)

HIGHLIGHT:
  --hl-fg <0-255|#RRGGBB>   override highlight foreground (default is black)

EXAMPLES:
  zcolor 69
  zcolor 69 triadic --compact
  zcolor 69 -mono --text
  zcolor #ff1d81 complementary
  zcolor 46 tetradic --hl-fg 255

NOTES:
- Tokens beginning with '--' are options.
- Tokens beginning with '-' are only accepted as '-<mode>' (e.g. -mono). Others error.
- One color prints one deterministic line per palette entry.
EOF
}

# ------------------------------------------------------------------------------
# Unified render (one line per color)
# ------------------------------------------------------------------------------

_zc_render_line() {
  local id="$1" view="$2" hl_fg="$3"

  # Prefix
  printf "# %s  " "$id"

  case "$view" in
    compact)
      _zc_render_blocks "$id"
      _zc_render_dither "$id"
      ;;
    text)
      _zc_render_text "$id"
      ;;
    hud)
      _zc_render_blocks "$id"
      _zc_render_dither "$id"
      printf " "
      _zc_render_text "$id"
      ;;
    full|*)
      _zc_render_blocks "$id"
      _zc_render_dither "$id"
      printf "  "
      _zc_render_text "$id"
      printf "  "
      _zc_render_highlight "$id" "$hl_fg"
      ;;
  esac

  printf "\n"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

zcolor() {
  local mode=""
  local view="full"
  local hl_fg=""
  local -a colors=()
  local -a view_flags=()
  local token

  # Parse options anywhere, but enforce single view.
  # Also accept mode aliases like -mono.
  while (( $# > 0 )); do
    token="$1"
    shift

    case "$token" in
      --help|-h)
        _zc_help; return 0
        ;;
      --full|--compact|--text|--hud)
        view_flags+=("$token")
        ;;
      --hl-fg)
        (( $# == 0 )) && { print -u2 "zcolor: --hl-fg requires a value"; return 1; }
        hl_fg="$1"; shift
        if ! _zc_is_ansi256 "$hl_fg" && ! _zc_is_hex "$hl_fg"; then
          print -u2 "zcolor: invalid --hl-fg '$hl_fg' (use 0-255 or #RRGGBB)"
          return 1
        fi
        ;;
      -mono|-monochrome|-triadic|-analogous|-complementary|-tetradic|-square)
        mode="${token#-}"
        ;;
      --*)
        print -u2 "zcolor: unknown option '$token'"
        return 1
        ;;
      -*)
        # Any other single-dash token is an error, never a color.
        print -u2 "zcolor: unknown flag '$token' (single-dash only allowed for -<mode>)"
        return 1
        ;;
      mono|monochrome|triadic|analogous|complementary|tetradic|square)
        if [[ -n "$mode" && "$mode" != "$token" ]]; then
          print -u2 "zcolor: multiple modes specified ($mode, $token)"
          return 1
        fi
        mode="$token"
        ;;
      *)
        if _zc_is_ansi256 "$token" || _zc_is_hex "$token"; then
          colors+=("$token")
        else
          print -u2 "zcolor: ignoring invalid token '$token'"
        fi
        ;;
    esac
  done

  # Resolve view
  if (( ${#view_flags[@]} > 1 )); then
    print -u2 "zcolor: multiple view flags specified (${(j:, :)view_flags})"
    return 1
  elif (( ${#view_flags[@]} == 1 )); then
    view="${view_flags[1]#--}"
  fi

  (( ${#colors[@]} == 0 )) && { _zc_help; return 1; }

  local c p
  for c in "${colors[@]}"; do
    local -a palette
    palette=( $(_zc_palette "$c" "$mode") ) || return 1
    for p in "${palette[@]}"; do
      _zc_render_line "$p" "$view" "$hl_fg"
    done
  done
}
