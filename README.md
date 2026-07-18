# clearn

**Learn anything, see it clearly.** `clearn` is a small [Claude Code](https://claude.com/claude-code)
skill pack that turns "I don't get this" into a beautiful, self-contained HTML
explainer — diagrams, analogies, and a first-principles walkthrough pitched at
*you don't know this yet*.

Two commands:

- **`/learn <thing>`** — teach me this from the ground up. Produces a diagram-rich
  lesson: the big idea, a mental model, worked examples, a glossary, and where to
  go next.
- **`/explain <thing>`** — orient me at a high level. Produces a map: the key
  pieces, how they fit, and the one mental model that makes the rest click. Great
  for "what is this codebase / file / concept actually doing?"

Each command hands your question to a dedicated agent that researches and reasons,
then writes a **single self-contained `.html` file** (styled like a polished
explainer, with [Mermaid](https://mermaid.js.org/) diagrams) and opens it in your
browser. Nothing to host, nothing to install beyond the skills themselves.

> Status: early. See the [issues](https://github.com/mengsig/clearn/issues) for the
> roadmap. Built with Claude Code.

## Quick start

```sh
git clone https://github.com/mengsig/clearn.git
cd clearn
./install.sh            # copies the skills into ~/.claude/skills
```

Then, from any Claude Code session:

```
/learn how does the TCP three-way handshake actually work
/explain what is going on in this repository
```

An HTML explainer opens in your browser.

## What makes it different

- **Assumes you don't know it yet.** No hand-waving, no jargon without a plain-word
  gloss. Every new term is introduced before it is used.
- **Diagrams first.** The mental model is drawn, not just described.
- **Self-contained.** One `.html` file you can keep, share, or open offline.
- **Two altitudes.** `/learn` teaches; `/explain` orients.

## License

MIT — see [LICENSE](LICENSE).
