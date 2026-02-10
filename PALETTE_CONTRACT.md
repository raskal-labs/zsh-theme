## Prompt roles (authoritative)

These roles MUST be defined by every palette and are consumed
only by the prompt renderer.

PALETTE_PROMPT_FG        Default prompt foreground
PALETTE_PROMPT_HOST      Host / environment label
PALETTE_PROMPT_ANCHOR    Path anchor (~, /box, /)
PALETTE_PROMPT_PATH      Path tail
PALETTE_PROMPT_OK        Prompt glyph (success)
PALETTE_PROMPT_ERR       Prompt glyph (error)

## Global semantic roles

These roles are shared across ls, completion menus, syntax
highlighting, and other UI surfaces.

PALETTE_FG          – default foreground / neutral text
PALETTE_BG          – background control (0 = black trigger only)
PALETTE_ENV         – hostname / environment identity (non-prompt)
PALETTE_SCOPE       – anchors, emphasis, selection, grep hits
PALETTE_PATH        – paths, locations, navigational elements
PALETTE_DIR         – directories (ls, completion)
PALETTE_FILE        – regular files (ls, completion)
PALETTE_SUCCESS     – success state, executable, ok status
PALETTE_ERROR       – error state, failure status
PALETTE_INPUT       – typed commands
PALETTE_STRING      – quoted strings
PALETTE_CONST       – constants / literals
PALETTE_SUGGESTION  – autosuggestions, comments, hints
