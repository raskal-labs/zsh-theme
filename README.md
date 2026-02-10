# zsh-theme (private)

Semantic Zsh theming engine.

- Palette-driven
- Zsh-only
- No runtime deps
- Designed to be boring and stable

See:
- PALETTE_CONTRACT.md
- zsh-theme.sh
- 5f279f8 (freeze palette roles)

### zcolor (v1)

Deterministic color inspection tool for ANSI-256 and HEX colors.

**Guarantees**
- One color renders as one line.
- Palette modes activate only when explicitly requested.
- Flags never render as colors.
- ANSI (0–255) and HEX (#RRGGBB) supported.
- zsh-only; no bash support.

**Modes**
mono, analogous, complementary, triadic, tetradic, square

**Views**
--full (default), --compact, --text, --hud

**Status**
v1 behavior is frozen. Changes require a version bump.

### zpalette

Palette inspection and future palette tooling.

**Preview**
```sh
zpalette preview electric
# or simply
zpalette electric
