---
name: learn
description: Turn "I don't understand X" into a self-contained, diagram-rich HTML explainer that teaches X from first principles, then opens it in the browser. Use when the user types /learn <topic> or asks to be taught something they do not yet understand.
---

# /learn — teach me this from the ground up

The user wants to learn something they do **not** understand yet. Produce a
beautiful, self-contained HTML **explainer** that teaches it from first principles,
save it, and open it in their browser. The explainer is the deliverable — your chat
reply stays short.

## 1. Read the request

The text after `/learn` is the topic (e.g. `/learn how TLS actually works`). If
it's empty, ask what they'd like to learn. Only ask a clarifying question if the
topic is *genuinely* ambiguous — an acronym with several common meanings, or no
clear referent — and then ask **exactly one** short question. Otherwise do not
interrogate: assume a motivated beginner and proceed. If they signalled a level
("I know some Python", "I'm a designer, not a coder"), honor it.

If the topic is a **GitHub PR or issue reference** (`#123`, `owner/repo#123`, a
pull/issues URL), fetch it read-only exactly as the `explain` skill's "FETCH it"
step describes (resolve the repo from the git remote; `gh pr view` / `gh pr diff`,
falling back to `gh issue view`; needs `gh` authenticated). Then teach it as a
**lesson**: what the change does *and* the underlying concepts a newcomer needs to
follow it — not just an orientation map (that's what `/explain #123` is for).

## 2. Hand it to a dedicated explainer agent

Delegate the research and authoring to a subagent (the Task/Agent tool, a
general-purpose agent) so this session stays light and the explainer gets focused
effort. Give the subagent: the topic, the learner's assumed starting point, the
output path (§4), and the **authoring contract** below verbatim. Wait for it, then
report the path it wrote. If delegation isn't available, do it yourself under the
same contract.

## 3. Authoring contract (put this in the subagent's brief)

Produce ONE self-contained `.html` explainer:

- **Base it on the clearn template** if you can reach it — check, in order:
  `templates/learning-artifact.html` in a clearn checkout, then
  `~/.claude/skills/clearn/assets/learning-artifact.html` (installed). Its full
  design principles live in `docs/artifact-design.md` (or the bundled
  `~/.claude/skills/clearn/assets/artifact-design.md`). Copy the template and
  replace the content between its `<!-- FILL: … -->` markers, keeping the `<style>`
  and `<script>` intact. **If neither file is reachable, still build a
  self-contained HTML file that honors the principles below** — the template is an
  accelerator, not a hard dependency.
- **Teach for someone who does not know this yet:** motivate before mechanism
  (why it exists / what problem it solves, before how it works); introduce every
  term before using it; no unexplained jargon; find the single mental model that
  makes the rest click and keep returning to it.
- **Include:** an honest header (difficulty · prerequisites · reading time); a
  one-sentence **big idea** a reader could stop at and still gain something true;
  3–6 lesson steps that build on each other; a **Mermaid diagram** of the mental
  model in most steps (pick the fitting type — flowchart / sequence / state /
  mindmap); at least one analogy callout and one concrete **worked example**
  (code, numbers, a walked-through case); a glossary of every term introduced;
  2–3 check-your-understanding questions (answers hidden in `<details>`); and
  honest, specific next steps.
- **Self-contained:** inline CSS/JS only. The sole external dependency is the
  Mermaid import in the template — keep it and its graceful offline fallback.
  Theme-awareness and responsiveness come from the template; don't fight them.
  **Never put information only in a diagram** (the source must still read if
  Mermaid can't load).
- **Be accurate.** Flag genuine uncertainty ("roughly", a caveat callout); point to
  primary sources in "where to go next" for anything the reader will act on.

## 4. Save and open

Write to the output directory: `$CLEARN_OUT` if set, otherwise `./out` (create it
if missing). Filename: `<topic-slug>-learn.html`. Then open it:

- macOS: `open <file>` · Linux: `xdg-open <file>` · Windows: `start <file>`

If no opener works, print the absolute path. Finish by telling the user the
one-sentence big idea and the file path — nothing more.
