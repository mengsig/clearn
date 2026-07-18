#!/usr/bin/env bash
# clearn installer — copy the /learn and /explain skills (and their shared design
# assets) into a Claude Code skills directory so the slash commands work in any
# session.
#
#   ./install.sh                 install into ~/.claude/skills
#   ./install.sh --uninstall     remove a clearn install from there
#   ./install.sh --dir <path>    install into <path> instead (e.g. a project's
#                                .claude/skills for project-scoped use)
#   ./install.sh --help
#
# Safe by design: it only ever writes/removes directories it created, marked with
# a `.clearn-managed` sentinel. It refuses to clobber a skill of the same name it
# did not install, so your own `learn`/`explain` skills are never overwritten.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DEST="${HOME}/.claude/skills"
ACTION="install"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --uninstall) ACTION="uninstall"; shift ;;
    --dir) DEST="${2:?--dir needs a path}"; shift 2 ;;
    -h|--help)
      sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown argument: $1 (try --help)" >&2; exit 2 ;;
  esac
done

SKILLS="learn explain"
ASSET_DIR="clearn/assets"          # shared companion (not a skill itself)
SENTINEL=".clearn-managed"

say()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# is_ours <dir> -> 0 if the dir exists and carries our sentinel (safe to replace
# or remove). A non-existent dir is treated as "ours" (nothing to protect).
is_ours() { [ ! -e "$1" ] || [ -f "$1/$SENTINEL" ]; }

if [ "$ACTION" = "uninstall" ]; then
  removed=0
  for s in $SKILLS; do
    d="$DEST/$s"
    [ -e "$d" ] || continue
    if [ -f "$d/$SENTINEL" ]; then rm -rf "$d"; removed=$((removed + 1)); say "removed $d"
    else warn "skipping $d — not installed by clearn (no $SENTINEL); leaving it alone"; fi
  done
  ad="$DEST/clearn"
  if [ -e "$ad" ]; then
    if [ -f "$ad/$SENTINEL" ]; then rm -rf "$ad"; removed=$((removed + 1)); say "removed $ad"
    else warn "skipping $ad — not installed by clearn; leaving it alone"; fi
  fi
  [ "$removed" -gt 0 ] && say "clearn uninstalled from $DEST." || say "nothing to uninstall in $DEST."
  exit 0
fi

# --- install ---------------------------------------------------------------
[ -f "$SRC/templates/learning-artifact.html" ] || die "run this from a clearn checkout (missing templates/learning-artifact.html)"

# Refuse to clobber a same-named skill we don't own, before writing anything.
for s in $SKILLS; do
  is_ours "$DEST/$s" || die "$DEST/$s already exists and was not installed by clearn. Move it aside, then re-run."
done
is_ours "$DEST/clearn" || die "$DEST/clearn already exists and was not installed by clearn. Move it aside, then re-run."

mkdir -p "$DEST"
for s in $SKILLS; do
  rm -rf "$DEST/$s"
  mkdir -p "$DEST/$s"
  cp "$SRC/.claude/skills/$s/SKILL.md" "$DEST/$s/SKILL.md"
  : > "$DEST/$s/$SENTINEL"
  say "installed skill: $s"
done

# Shared design assets, discoverable by both skills at ~/.claude/skills/clearn/assets.
rm -rf "$DEST/clearn"
mkdir -p "$DEST/$ASSET_DIR"
cp "$SRC/templates/learning-artifact.html" "$DEST/$ASSET_DIR/learning-artifact.html"
cp "$SRC/docs/artifact-design.md" "$DEST/$ASSET_DIR/artifact-design.md"
: > "$DEST/clearn/$SENTINEL"
say "installed shared assets: $ASSET_DIR"

say ""
say "clearn installed into $DEST"
say "Start (or restart) a Claude Code session and try:"
say "    /learn how does the TCP three-way handshake work"
say "    /explain what is going on in this repository"
say ""
say "Explainers are written to \$CLEARN_OUT (default ./out) and opened in your browser."
