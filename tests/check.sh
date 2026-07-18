#!/usr/bin/env bash
# tests/check.sh — clearn verification harness.
#
# Asserts clearn's integrity guarantees over the REAL files in the repo, so a
# contributor can verify a change with one command instead of by hand:
#
#     bash tests/check.sh      # exit 0 = all passed, non-zero = something failed
#
# What it checks (offline, no network):
#   - templates/learning-artifact.html: its embedded JS parses; it has exactly
#     one own-line <style>/<script> block; its Mermaid labels obey strict mode.
#   - every examples/*.html: JS parses; its <style> and <script> blocks are
#     byte-identical to the template (the self-contained design-system
#     invariant); it carries no unfilled <!-- FILL: --> region and none of the
#     template's placeholder demo content; its Mermaid labels obey strict mode.
#   - the two skills: YAML frontmatter has a name: and description:, and name:
#     equals the skill's directory name.
#   - install.sh (against a throwaway temp dir, NEVER ~/.claude): syntax; a real
#     install produces the expected layout; it refuses to clobber a foreign
#     same-named skill; --uninstall spares a foreign skill.
#
# Requirements: bash, awk, sed, grep, diff, and `node` (only for the JS-parse
# checks — if node is absent those checks are SKIPPED with a visible warning
# rather than failing). Portable to macOS bash 3.2 and Linux: no mapfile, no
# associative arrays, no ${var^^}; grep matches use here-strings (piping into
# `grep -q` under `set -euo pipefail` SIGPIPEs the producer to exit 141).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

TEMPLATE="templates/learning-artifact.html"

PASS=0; FAIL=0; SKIP=0
ok()   { PASS=$((PASS + 1)); printf '  ok    %s\n' "$1"; }
bad()  { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$1"; }
skip() { SKIP=$((SKIP + 1)); printf '  skip  %s (%s)\n' "$1" "$2"; }

# check "<name>" '<cmd>' — run the assertion, tally pass/fail, and surface the
# assertion's own diagnostic output only when it fails. The `if out=$(...)` form
# keeps `set -e` from aborting the harness on an expected non-zero assertion.
check() {
  name="$1"; shift
  out=""
  if out="$(eval "$*" 2>&1)"; then ok "$name"
  else bad "$name"; [ -n "$out" ] && printf '%s\n' "$out"; fi
}

# --- shared extractors -------------------------------------------------------

# extract_inner FILE TAG — print the lines strictly between an own-line <TAG>
# and its own-line </TAG> (the tags themselves excluded). "Own-line" avoids the
# template's head-comment mention of "<script> blocks" and the inline
# "<pre class=..></pre>" in that comment.
extract_inner() {
  awk -v tag="$2" '
    BEGIN { o = "^[[:space:]]*<" tag ">[[:space:]]*$"; c = "^[[:space:]]*</" tag ">[[:space:]]*$" }
    $0 ~ o { p = 1; next }
    $0 ~ c { if (p) p = 0; next }
    p' "$1"
}

# mermaid_block FILE — print the inner content of every own-line <pre class="mermaid"> block.
mermaid_block() {
  awk '
    /^[[:space:]]*<pre class="mermaid">[[:space:]]*$/ { p = 1; next }
    /^[[:space:]]*<\/pre>[[:space:]]*$/ { if (p) p = 0; next }
    p' "$1"
}

# --- assertions (silent on success; echo a reason and return non-zero on failure) ---

js_parses() {  # FILE — extract the <script> body and run `node --check`
  f="$1"
  d="$(mktemp -d "${TMPDIR:-/tmp}/clearn-js.XXXXXX")" || { echo "  cannot mktemp"; return 1; }
  js="$d/embedded.js"       # node --check needs a known extension
  extract_inner "$f" script > "$js"
  rc=0
  if [ ! -s "$js" ]; then echo "  $f: no <script> block found"; rc=1
  else node --check "$js" || rc=$?; fi
  rm -rf "$d"
  return "$rc"
}

one_block() {  # FILE TAG — exactly one own-line open and one own-line close tag
  op="$(grep -cE "^[[:space:]]*<${2}>[[:space:]]*"'$' "$1" || true)"
  cl="$(grep -cE "^[[:space:]]*</${2}>[[:space:]]*"'$' "$1" || true)"
  [ "$op" = 1 ] && [ "$cl" = 1 ] && return 0
  echo "  $1: own-line <$2> open=$op close=$cl (want 1 and 1)"; return 1
}

blocks_identical() {  # EXAMPLE TAG — example's <TAG> block byte-identical to the template's
  d="$(diff <(extract_inner "$TEMPLATE" "$2") <(extract_inner "$1" "$2"))" || {
    echo "  $1: <$2> block differs from $TEMPLATE:"; echo "$d"; return 1; }
  return 0
}

mermaid_labels_ok() {  # FILE — strict-Mermaid label rule
  block="$(mermaid_block "$1")"
  # <br/> is never part of an arrow operator, so it is forbidden anywhere in a block.
  if grep -qE '<br[[:space:]]*/?>' <<<"$block"; then
    echo "  $1: <br> inside a pre.mermaid block"; return 1
  fi
  # { } < > $ are forbidden inside label TEXT — the quoted ["…"] parts. Shape
  # delimiters ({ }) and arrow operators (-->) live outside the quotes, so scan
  # only the double-quoted strings.
  labels="$(grep -oE '"[^"]*"' <<<"$block" || true)"
  bad="$(grep -nE '[{}<>$]' <<<"$labels" || true)"
  [ -z "$bad" ] && return 0
  echo "  $1: forbidden char in Mermaid label(s):"; echo "$bad"; return 1
}

no_unfilled_template() {  # FILE — no surviving FILL marker, no placeholder demo content
  if grep -q '<!-- FILL:' "$1"; then echo "  $1: still has an unfilled <!-- FILL: --> region"; return 1; fi
  if grep -q 'slots\[' "$1"; then echo "  $1: still contains the template's placeholder demo content (slots[…])"; return 1; fi
  return 0
}

skill_frontmatter_ok() {  # SKILL_DIR (learn|explain)
  f=".claude/skills/$1/SKILL.md"
  [ -f "$f" ] || { echo "  missing $f"; return 1; }
  # Frontmatter is the block between a leading '---' and the next '---'.
  fm="$(awk 'NR==1 && $0=="---"{f=1;next} f && $0=="---"{exit} f' "$f")"
  name="$(sed -n 's/^name:[[:space:]]*//p' <<<"$fm")"
  desc="$(sed -n 's/^description:[[:space:]]*//p' <<<"$fm")"
  [ -n "$desc" ] || { echo "  $1: no description: in frontmatter"; return 1; }
  [ -n "$name" ] || { echo "  $1: no name: in frontmatter"; return 1; }
  [ "$name" = "$1" ] || { echo "  $1: frontmatter name '$name' != directory name '$1'"; return 1; }
  return 0
}

# --- installer assertions (each in its own throwaway DEST; never ~/.claude) ---

install_produces_layout() {
  d="$(mktemp -d "${TMPDIR:-/tmp}/clearn-inst.XXXXXX")" || { echo "  cannot mktemp"; return 1; }
  ret=0
  if ! bash "$ROOT/install.sh" --dir "$d" >/dev/null 2>&1; then echo "  install exited non-zero"; ret=1
  elif [ ! -f "$d/learn/SKILL.md" ];    then echo "  missing learn/SKILL.md"; ret=1
  elif [ ! -f "$d/explain/SKILL.md" ];  then echo "  missing explain/SKILL.md"; ret=1
  elif [ ! -f "$d/clearn/assets/learning-artifact.html" ]; then echo "  missing clearn/assets/learning-artifact.html"; ret=1
  fi
  rm -rf "$d"; return "$ret"
}

install_refuses_foreign() {
  d="$(mktemp -d "${TMPDIR:-/tmp}/clearn-inst.XXXXXX")" || { echo "  cannot mktemp"; return 1; }
  mkdir -p "$d/learn"; printf 'foreign\n' > "$d/learn/SKILL.md"; : > "$d/learn/FOREIGN"
  ret=0
  if bash "$ROOT/install.sh" --dir "$d" >/dev/null 2>&1; then echo "  install did NOT refuse a foreign learn/"; ret=1
  elif [ ! -f "$d/learn/FOREIGN" ];              then echo "  the foreign learn/ was disturbed"; ret=1
  elif [ -f "$d/learn/.clearn-managed" ];        then echo "  install stamped its sentinel onto a foreign dir"; ret=1
  elif ! grep -q foreign "$d/learn/SKILL.md";    then echo "  the foreign SKILL.md was overwritten"; ret=1
  fi
  rm -rf "$d"; return "$ret"
}

uninstall_spares_foreign() {
  d="$(mktemp -d "${TMPDIR:-/tmp}/clearn-inst.XXXXXX")" || { echo "  cannot mktemp"; return 1; }
  ret=0
  if ! bash "$ROOT/install.sh" --dir "$d" >/dev/null 2>&1; then
    echo "  setup install failed"; rm -rf "$d"; return 1
  fi
  # Turn the installed learn/ into a foreign skill: drop the sentinel, mark it.
  rm -f "$d/learn/.clearn-managed"; : > "$d/learn/FOREIGN"
  if ! bash "$ROOT/install.sh" --dir "$d" --uninstall >/dev/null 2>&1; then echo "  --uninstall exited non-zero"; ret=1
  elif [ ! -f "$d/learn/FOREIGN" ];  then echo "  --uninstall removed the foreign learn/"; ret=1
  elif [ -e "$d/explain" ];          then echo "  --uninstall left clearn's explain/ behind"; ret=1
  elif [ -e "$d/clearn" ];           then echo "  --uninstall left clearn's assets behind"; ret=1
  fi
  rm -rf "$d"; return "$ret"
}

# --- run the checks ----------------------------------------------------------

NODE_OK=1
if ! command -v node >/dev/null 2>&1; then
  NODE_OK=0
  printf 'WARNING: node not found on PATH — JS-parse checks will be SKIPPED.\n\n' >&2
fi

echo "== template ($TEMPLATE) =="
[ -f "$TEMPLATE" ] || { echo "FATAL: $TEMPLATE not found (run from a clearn checkout)"; exit 2; }
if [ "$NODE_OK" = 1 ]; then check "template: embedded JS parses" "js_parses '$TEMPLATE'"
else skip "template: embedded JS parses" "node absent"; fi
check "template: exactly one <style> block"  "one_block '$TEMPLATE' style"
check "template: exactly one <script> block" "one_block '$TEMPLATE' script"
check "template: Mermaid labels obey strict mode" "mermaid_labels_ok '$TEMPLATE'"

echo "== examples =="
for f in examples/*.html; do
  [ -e "$f" ] || { echo "FATAL: no examples/*.html found"; exit 2; }
  if [ "$NODE_OK" = 1 ]; then check "$f: embedded JS parses" "js_parses '$f'"
  else skip "$f: embedded JS parses" "node absent"; fi
  check "$f: <style> byte-identical to template"  "blocks_identical '$f' style"
  check "$f: <script> byte-identical to template" "blocks_identical '$f' script"
  check "$f: no unfilled template region"          "no_unfilled_template '$f'"
  check "$f: Mermaid labels obey strict mode"      "mermaid_labels_ok '$f'"
done

echo "== skills =="
check "skill learn: frontmatter name+description" "skill_frontmatter_ok learn"
check "skill explain: frontmatter name+description" "skill_frontmatter_ok explain"

echo "== installer (install.sh, throwaway temp dirs) =="
check "install.sh: bash syntax" "bash -n '$ROOT/install.sh'"
check "install: produces expected layout"        "install_produces_layout"
check "install: refuses a foreign same-named skill" "install_refuses_foreign"
check "uninstall: spares a foreign skill"         "uninstall_spares_foreign"

echo
echo "== summary =="
printf '  %d passed, %d failed, %d skipped\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ]
