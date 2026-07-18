---
name: explain
description: Give a high-level, diagram-rich HTML orientation to a concept, a file, or a whole codebase — the big picture, the key pieces, how they fit, and the one mental model that makes the rest click. Use when the user types /explain <thing> or asks "what is going on here at a high level".
---

# /explain — orient me at a high level

The user wants the **map**, not a from-scratch course: what this thing is, its key
pieces, how they fit together, and the single mental model that makes the rest
click. Produce a self-contained HTML **orientation**, save it, and open it. Keep
your chat reply short — the artifact is the deliverable.

`/explain` and `/learn` share the same output format and design system; they differ
in **altitude**. `/learn` teaches a topic from the ground up; `/explain` orients you
over something that already exists so you can navigate it. When in doubt: if the
user sounds lost in a *thing* (a repo, a file, a system), use `/explain`; if they
want to *understand a concept* they don't know, that's `/learn`.

## 1. Read the request

The text after `/explain` names the target — a concept ("`/explain` CQRS"), or a
concrete artifact ("`/explain` what is going on in this repo", "`/explain` src/auth.ts").
If empty, ask what to orient them on. Don't interrogate otherwise.

## 2. If it points at real code, READ it first

When the target is a file, directory, or "this repo/codebase", you must describe the
**actual** thing, not a generic one. Delegate exploration to a subagent (Task/Agent,
general-purpose): have it map the real entry points, modules, data flow, and the
handful of files that matter, and return that structure. Then the diagram reflects
reality. For a pure concept, delegate the research/authoring the same way. This
keeps the session light and the work focused. If delegation isn't available, do it
yourself.

## 3. Authoring contract (put this in the subagent's brief)

Produce ONE self-contained `.html` orientation, on the clearn design system:

- **Base it on the clearn template** if reachable — `templates/learning-artifact.html`
  in a clearn checkout, else `~/.claude/skills/clearn/assets/learning-artifact.html`;
  principles in `docs/artifact-design.md` (or the bundled copy). Copy it and replace
  the content between the `<!-- FILL: … -->` markers, keeping `<style>`/`<script>`
  intact. If neither is reachable, build a self-contained HTML file honoring the
  principles anyway.
- **Shape it as a map, not a course:** the big picture first; then the key pieces and
  **how they relate**; then the one mental model; then what to read next. Prefer a
  structural/flow diagram (flowchart of components + data flow, a `sequenceDiagram`
  for a request's journey, or a `mindmap` of the area) that shows the **real**
  relationships. Less first-principles teaching than `/learn` — assume the reader is
  capable, just new to *this*.
- **Ground every claim in the artifact.** When explaining code, name real files,
  functions, and the actual flow; link or reference concrete locations. Don't invent
  structure that isn't there.
- **Include:** an honest header; a one-sentence **big idea** ("this repo is X that
  does Y by Z"); the component map (with diagram); the mental model; a short glossary
  of the project's/topic's own terms; and specific "start here / read next" pointers.
- **Self-contained:** inline CSS/JS only; keep the Mermaid import and its offline
  fallback; theme-aware + responsive from the template; never put information only in
  a diagram.
- **Be accurate.** Flag uncertainty; don't overstate how much you inspected.

## 4. Save and open

Write to `$CLEARN_OUT` if set, else `./out` (create it if missing). Filename:
`<target-slug>-explain.html`. Open it — macOS `open`, Linux `xdg-open`, Windows
`start`; if none work, print the absolute path. Finish by telling the user the
one-sentence big idea and the path.
