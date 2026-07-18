---
name: explain
description: Give a high-level, diagram-rich HTML orientation to a concept, a file, a whole codebase, or a GitHub PR/issue — the big picture, the key pieces, how they fit, and the one mental model that makes the rest click. Use when the user types /explain <thing> (including /explain #123 or /explain owner/repo#123) or asks "what is going on here at a high level".
---

# /explain — orient me at a high level

The user wants the **map**, not a from-scratch course: what this thing is, its key
pieces, how they fit together, and the single mental model that makes the rest
click. Produce a self-contained HTML **orientation**, save it, and open it. Keep
your chat reply short — the artifact is the deliverable.

`/explain` and `/learn` share the same output format and design system; they differ
in **altitude**. `/learn` teaches a topic from the ground up; `/explain` orients you
over something that already exists so you can navigate it. When in doubt: if the
user sounds lost in a *thing* (a repo, a file, a system, a PR), use `/explain`; if
they want to *understand a concept* they don't know, that's `/learn`.

## 1. Read the request

The text after `/explain` names the target. It is one of:

- a **concept** — "`/explain` CQRS";
- a **file / directory / codebase** — "`/explain` src/auth.ts", "what is going on in this repo";
- a **GitHub PR or issue reference** — `#123`, `PR #123`, `issue #123`,
  `owner/repo#123`, `repo#123`, or a `https://github.com/…/pull/123` (or `/issues/123`) URL.

If it's empty, ask what to orient them on. Don't interrogate otherwise.

## 2a. If it names a GitHub PR or issue, FETCH it (read-only)

Resolve the repo `slug` (owner/repo):

- A full URL or `owner/repo#N` → use that owner/repo directly.
- `repo#N` or a bare `#N` / `PR #N` / `issue #N` → resolve from the current
  directory's git remote: `git remote get-url origin` (or `gh repo view --json nameWithOwner -q .nameWithOwner`), and parse `owner/repo`. If `repo#N` names a
  different repo than the current one and you can't resolve it, ask **one** short
  question ("which owner/repo?").
- No git remote and no explicit owner → ask that one question.

A number is either a PR **or** an issue (they share one numbering space). Try the PR
first, fall back to the issue:

```sh
# PR (preferred): metadata + the actual change
gh pr view <N> --repo <slug> --json title,body,state,author,url,baseRefName,headRefName,additions,deletions,changedFiles,files,commits,labels,reviewDecision,mergedAt
gh pr diff <N> --repo <slug>          # the diff; if it's huge, work from `files` + hunks, don't paste all of it
# if `gh pr view` fails, it's an issue:
gh issue view <N> --repo <slug> --json title,body,state,author,url,labels,comments
```

Reads are fine with plain `gh`. Never mutate anything (no comment, label, merge).
If `gh` is missing or unauthenticated, stop and say so plainly (this mode needs
`gh auth login`). Delegate the fetch **and** authoring to a subagent (§3) so this
session stays light.

## 2b. If it points at real code, READ it first

When the target is a file, directory, or "this repo/codebase", describe the
**actual** thing, not a generic one. Delegate exploration to a subagent: have it map
the real entry points, modules, data flow, and the files that matter, and return
that structure. (For a pure concept, delegate the research/authoring the same way.)
If delegation isn't available, do it yourself.

## 3. Authoring contract (put this in the subagent's brief)

Produce ONE self-contained `.html` orientation, on the clearn design system:

- **Base it on the clearn template** if reachable — `templates/learning-artifact.html`
  in a clearn checkout, else `~/.claude/skills/clearn/assets/learning-artifact.html`;
  principles in `docs/artifact-design.md` (or the bundled copy). Copy it and replace
  the content between the `<!-- FILL: … -->` markers, keeping `<style>`/`<script>`
  intact. If neither is reachable, build a self-contained HTML file honoring the
  principles anyway.
- **Shape it as a map, not a course.** Assume a capable reader, just new to *this*.
- **Ground every claim in the target.** Name real files, functions, PR numbers, and
  the actual flow; don't invent structure that isn't there.
- **Mermaid label rule:** the template pins `securityLevel: 'strict'`, which strips
  `<br/>`/`<b>` and rejects `{ } < > $` in node labels — keep labels short plain
  phrases, split multi-line ideas into separate nodes, no raw special characters.
  Never put information only in a diagram.

**For a PR**, the map is the change itself:
- **Big idea:** what this PR changes, in one sentence.
- **Why:** the problem/motivation (from the description and any linked issue).
- **The change map:** cluster the changed files by area and show how they relate
  (a `flowchart`), saying what each cluster does. Ground it in the real `files`/diff.
- **Approach & notable decisions;** anything subtle or risky.
- **What to review / risk:** the load-bearing changes, tests touched, edge cases.
- **Status chips:** open / merged / closed, review decision, size (files · +adds / −dels).
- Glossary of the project's terms; next steps (the key files to read, the linked issue).

**For an issue:** big idea (what's asked/reported), context & why it matters, what
"done" looks like, the likely code areas, discussion highlights, next steps.

**For a concept / codebase:** big picture → key pieces and how they relate (a
structural/flow diagram) → the one mental model → what to read next.

- **Self-contained:** inline CSS/JS only; keep the Mermaid import + offline fallback;
  theme-aware + responsive from the template. Flag uncertainty; don't overstate how
  much you inspected.

## 4. Save and open

Write to `$CLEARN_OUT` if set, else `./out` (create it if missing). Filename:
`<target-slug>-explain.html` — for a ref use e.g. `<repo>-pr-<N>-explain.html` /
`<repo>-issue-<N>-explain.html`. Open it — macOS `open`, Linux `xdg-open`, Windows
`start`; if none work, print the absolute path. Finish by telling the user the
one-sentence big idea and the path.
