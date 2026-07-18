<h1 align="center">clearn</h1>
<p align="center"><b>Learn anything, see it clearly.</b></p>
<p align="center">
  A <a href="https://claude.com/claude-code">Claude Code</a> skill pack that turns
  "I don't get this" into a beautiful, self-contained HTML explainer —
  diagrams, analogies, and a first-principles walkthrough pitched at
  <i>you don't know this yet</i>.
</p>

---

Two commands:

- **`/learn <thing>`** — teach me this from the ground up. You get a diagram-rich
  lesson: the big idea, a mental model, worked examples, a glossary, and where to
  go next.
- **`/explain <thing>`** — orient me at a high level. You get a map: the key pieces,
  how they fit, and the one mental model that makes the rest click. Great for
  "what is this codebase / file / concept actually doing?" — and it understands
  **GitHub PRs and issues**: `/explain #33`, `/explain owner/repo#33`, or a PR/issue
  URL produces a change map of what the PR does, why, and what to review.

Each command hands your question to a dedicated agent that researches and reasons,
then writes a **single self-contained `.html` file** (a polished explainer with
[Mermaid](https://mermaid.js.org/) diagrams) and opens it in your browser. Nothing
to host; nothing to install beyond the skills themselves.

## See it in action

Two explainers built with clearn's own design system (open them rendered):

- 📘 [**/learn** — How the TCP three-way handshake works](https://raw.githack.com/mengsig/clearn/main/examples/learn-tcp-handshake.html)
- 🗺️ [**/explain** — the clearn repo itself](https://raw.githack.com/mengsig/clearn/main/examples/explain-clearn.html)

(Or open the files under [`examples/`](examples/) locally — they work offline.)

## Quick start

```sh
git clone https://github.com/mengsig/clearn.git
cd clearn
./install.sh            # copies the skills into ~/.claude/skills
```

Restart your Claude Code session, then from anywhere:

```
/learn how does the TCP three-way handshake actually work
/explain what is going on in this repository
/explain #33                     # a PR or issue in the current repo
/explain owner/repo#412          # …or any repo you can reach with gh
```

An HTML explainer opens in your browser. GitHub references need the
[`gh` CLI](https://cli.github.com) authenticated (`gh auth login`). Full options — project-scoped install,
choosing the output directory, uninstall — are in [`docs/usage.md`](docs/usage.md).

## What makes it different

- **Assumes you don't know it yet.** No hand-waving, no jargon without a plain-word
  gloss. Every new term is introduced before it's used.
- **Diagrams first.** The mental model is drawn, not just described.
- **Self-contained.** One `.html` file you can keep, share, or open offline (Mermaid
  loads from a CDN; if it's unreachable, the diagram source stays readable).
- **Two altitudes.** `/learn` teaches; `/explain` orients.

## How it's built

| Piece | What it is |
|---|---|
| [`.claude/skills/learn`](.claude/skills/learn/SKILL.md) · [`explain`](.claude/skills/explain/SKILL.md) | The two skills — the workflow each command runs. |
| [`templates/learning-artifact.html`](templates/learning-artifact.html) | The self-contained, theme-aware design system every explainer uses. |
| [`docs/artifact-design.md`](docs/artifact-design.md) | The authoring judgment: reader model, altitudes, diagram choice, voice. |
| [`install.sh`](install.sh) | Copies the skills + assets into a Claude Code skills directory. |

New here? Start with an example above, then [`docs/artifact-design.md`](docs/artifact-design.md).

## Requirements

- Claude Code, and a browser to view explainers.
- macOS or Linux (the installer is a POSIX shell script); Windows works if you copy
  the skills in manually.
- Internet is optional — only for live Mermaid rendering; the source degrades
  gracefully.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Built with Claude Code.

## License

MIT — see [LICENSE](LICENSE).
