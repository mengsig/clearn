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

### GitHub PRs and issues

Both commands understand GitHub references:

```
/explain #33                 a PR or issue in the current repo (from its git remote)
/explain owner/repo#412       an explicit repo
/explain https://github.com/owner/repo/pull/33
/learn #33                    teach the concepts the PR involves, not just a map
```

`/explain #33` fetches the PR (or issue) read-only and produces a **change map**:
what it does, why, the clustered files it touches and how they relate, and what to
review. A bare `#N` resolves the repo from your current directory's git remote;
`owner/repo#N` or a URL names it explicitly.

This mode uses the [`gh` CLI](https://cli.github.com) and needs it authenticated
(`gh auth login`). It only ever **reads** — it never comments, labels, or merges.

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
