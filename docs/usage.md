# Installing and using clearn

clearn is two Claude Code skills — `learn` and `explain` — plus a shared design
system. You can use them **globally** (any session) or **per project**.

## Global install (recommended)

```sh
git clone https://github.com/mengsig/clearn.git
cd clearn
./install.sh
```

This copies the skills into `~/.claude/skills/` and their shared design assets into
`~/.claude/skills/clearn/assets/`. Restart your Claude Code session; `/learn` and
`/explain` are now available everywhere.

Remove them the same way:

```sh
./install.sh --uninstall
```

The installer only ever touches directories it created (marked with a
`.clearn-managed` sentinel), so a `learn`/`explain` skill of your own is never
overwritten or deleted.

## Per-project install

To scope the skills to one repository, install into that repo's `.claude/skills`:

```sh
/path/to/clearn/install.sh --dir /path/to/your-repo/.claude/skills
```

Or simply copy `.claude/skills/learn` and `.claude/skills/explain` into the
project. When run inside a clearn checkout itself, the skills find the design
template at `templates/learning-artifact.html` automatically.

## Using it

From any session where the skills are available:

```
/learn <something you don't understand yet>
/explain <a concept, a file, or "what is going on in this repo">
```

Each command hands your question to a dedicated agent, which writes a single
self-contained `.html` explainer and opens it in your browser.

- **`/learn`** teaches a topic from first principles.
- **`/explain`** orients you over something that already exists (a codebase, a
  file, a system) — the map and the mental model.

### Where explainers are written

By default, into `./out/` in the current directory (git-ignored in this repo). Set
`CLEARN_OUT` to choose a different directory:

```sh
export CLEARN_OUT="$HOME/clearn-explainers"
```

The files are self-contained — keep them, share them, or open them offline (Mermaid
diagrams load from a CDN; if it's unreachable the diagram source stays readable).

## Requirements

- Claude Code.
- A browser to view the explainers.
- Internet for live Mermaid rendering (optional — the source degrades gracefully).

No build step, no package manager, no runtime dependency.

## Packaging as a plugin

The copy-in installer above is the supported path today. If you distribute skills
through a Claude Code plugin/marketplace, point it at the `.claude/skills/learn`
and `.claude/skills/explain` directories and ship `templates/learning-artifact.html`
+ `docs/artifact-design.md` alongside them as `clearn/assets/`.
