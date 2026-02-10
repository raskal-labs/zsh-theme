# electric.sh — palette data only (no logic)
# All prompt + theme colors originate here.

# ----------------------------
# Prompt roles (authoritative)
# ----------------------------
PALETTE_PROMPT_FG=255        # near-white default text
PALETTE_PROMPT_HOST=214      # amber hostname/environment
PALETTE_PROMPT_ANCHOR=199    # hot pink anchor (~, /box, /)
PALETTE_PROMPT_PATH=51       # teal path tail
PALETTE_PROMPT_OK=82         # green prompt glyph on success
PALETTE_PROMPT_ERR=196       # red prompt glyph on error

# ----------------------------
# Filesystem / listings
# ----------------------------
PALETTE_DIR=31               # dark teal-blue directories (darker than prompt path)
PALETTE_FILE=255             # near-white files (high luminosity)
PALETTE_LINK=199             # symlinks (indirection)

# ----------------------------
# States / feedback
# ----------------------------
PALETTE_SUCCESS=82           # success state (also executable)
PALETTE_ERROR=196            # error state

# ----------------------------
# Syntax / editor-like roles
# ----------------------------
PALETTE_INPUT=255            # typed commands
PALETTE_STRING=214           # strings
PALETTE_CONST=199            # constants/literals
PALETTE_SUGGESTION=244       # autosuggestions/comments/hints

# ----------------------------
# Global / terminal background hint
# ----------------------------
PALETTE_FG=255               # general foreground (non-prompt contexts)
PALETTE_BG=0                 # 0 triggers optional background forcing
