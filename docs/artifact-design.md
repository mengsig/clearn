# Learning-artifact design

How to turn a question into a `clearn` explainer that is genuinely clear. Both
`/learn` and `/explain` produce one self-contained HTML file by copying
`templates/learning-artifact.html` and replacing the content between the
`<!-- FILL: … -->` markers. This doc is the judgment that goes into that.

## The reader

Assume a **motivated person who does not know this yet.** They are smart but new.
That single assumption drives everything:

- **Introduce every term before you use it.** If you must use a word the reader
  might not know, define it in the same breath or in the glossary.
- **No unexplained jargon, no hand-waving.** "It just works" is a failure. If
  something is genuinely deep, say so and give the honest one-level-down reason.
- **Motivate before mechanism.** Say *why the idea exists / what problem it solves*
  before *how it works*. A mechanism with no motivation doesn't stick.
- **One mental model.** Find the single picture that makes the rest click, and
  return to it. The reader should leave with a model, not a pile of facts.

## The two altitudes

| | `/learn` | `/explain` |
|---|---|---|
| Intent | Teach from the ground up | Orient at a high level |
| Reader leaves with | A working understanding they can build on | A map and the one mental model |
| Shape | 3–6 lesson steps that build on each other | Big picture → key pieces → how they fit → what to read next |
| Depth | First principles, worked example | Just enough to navigate; link to depth |
| Diagrams | Explain each concept | Show structure / flow / relationships |

When `/explain` is pointed at a real artifact (a file, a repo), the content must
describe the **actual** thing — read it first and diagram its real structure.
Never ship a generic diagram where a specific one is possible.

## Structure (the template's regions)

1. **Header** — topic, a one-line subtitle that states the payoff, and honest meta
   chips (difficulty, prerequisites, reading time). Don't inflate difficulty.
2. **The big idea (TL;DR)** — the single most important takeaway in 1–2 sentences.
   A reader who stops here should still gain something true.
3. **Contents** — name the steps so the reader sees the arc.
4. **Lesson steps** — each builds on the last. A good step has: a short prose
   explanation, a **diagram** of the idea, an **analogy** callout, and a
   **concrete example** (code, numbers, a walked-through case).
5. **Glossary** — define every term you introduced.
6. **Check your understanding** — 2–3 questions with hidden answers that test the
   *model*, not recall of trivia.
7. **Where to go next** — honest, specific follow-ups (ideally linked).

Not every explainer needs every region — but never drop the big idea, at least
one diagram, and the glossary.

## Diagrams

Draw the mental model; don't just describe it. Pick the Mermaid type that fits:

- **`flowchart`** — steps, decisions, "A leads to B", data flow, structure.
- **`sequenceDiagram`** — who talks to whom over time (handshakes, request/response,
  protocols). Use when *ordering between actors* is the point.
- **`stateDiagram-v2`** — a thing that moves between states (a connection, a parser).
- **`mindmap`** — the shape of a topic / how subtopics relate (great for `/explain`
  overviews).
- **`erDiagram` / `classDiagram`** — data models and relationships.

Rules:
- Keep each diagram to one idea. Two small diagrams beat one crowded one.
- **Never put information only in a diagram.** If Mermaid can't load, the source
  stays visible — the prose plus the source must still carry the point.
- Label edges with verbs ("hashes to", "sends", "returns"). Highlight the one node
  that matters with a fill (see the template).

## Self-contained, always

- One `.html` file. Inline CSS/JS only. The sole external dependency is the Mermaid
  import already in the template — keep it, and keep the graceful-fallback script.
- No tracking, no fonts from the network, no images fetched at runtime. Embed a
  small SVG inline if you truly need a picture.
- Theme-aware and responsive come for free from the template — don't fight it.
  Test nothing renders wider than the screen except inside a scroll box.

## Voice

Warm, direct, concrete. Short sentences. Second person ("you"). Enthusiasm is fine;
filler is not. Prefer a vivid concrete example over an abstract restatement. It is
an explainer, not a lecture — respect the reader's time and intelligence.

## Honesty

The explainer is generated. Keep claims defensible: if you're unsure, say "roughly"
or give the caveat (see the O(1) "watch out" callout in the template). Point to
primary sources in *where to go next* for anything the reader will act on.
