---
description: Capture durable knowledge into the Obsidian vault — lesson, decision, preference, reference, or glossary
argument-hint: "[l|d|p|r|g | lesson|decision|preference|reference|glossary] [slug or term]"
---

Capture the conversation's durable takeaway as a structured, tagged note in the right Obsidian vault folder, linked from the project's `next.md`. One command, five categories.

## Step 0 — Route the invocation

`$ARGUMENTS` — parse as `[category] [slug/term…]`:

- **First token → category.** Accept the full word or its first letter:
  `l` / `lesson` · `d` / `decision` · `p` / `preference` · `r` / `reference` · `g` / `glossary`
- **Remaining tokens → the slug** (or, for glossary, the term). Optional except for glossary.
- **No arguments at all** → ask the user which category fits, using this framing:
  - **lesson** — something bit us; the going-forward rule is the point
  - **decision** — chose between real alternatives; the rationale will matter again
  - **preference** — how the user likes things done; should stick across sessions
  - **reference** — an external resource worth knowing how to find
  - **glossary** — a term that needs a one-place definition
- First token that matches no category → treat ALL tokens as the slug and infer the category from the conversation; confirm the inference in your report.

## Step 1 — Resolve the vault and project

If `~/.claude/CLAUDE.md` defines a **vault registry** (multi-vault setup), resolve the target vault by its rules first — explicit user instruction > repo `CLAUDE.md` declaration > pattern match > ask. Team vaults are typically single-project: notes go to `<vault>/sources/<category-folder>/` and `next.md` is `<vault>/journal/next.md`; `git pull` before writing, push at session wrap.

Otherwise (single-vault setup), the vault root is `{{VAULT_ROOT}}` and paths follow the multi-project form below.

**Project** (multi-project vaults): cwd basename, lowercased, mapped to `sources/projects/<project>/`. If the basename doesn't map cleanly, ask — don't guess silently.

## Step 2 — Compose the note (category specs below)

Common to all categories:

- **Path:** multi-project vaults: `<vault>/sources/projects/<project>/<folder>/<name>.md`; single-project vaults: `<vault>/sources/<folder>/<name>.md`. Create the folder if missing. `<name>` is `YYYY-MM-DD-<slug>` for all categories **except glossary** (bare term slug — timeless).
- **Frontmatter:** always YAML, always tagged. Semantic tags; hierarchical `area/subarea` where it helps (`git/safety`, `external/vendor`).
- **Wikilinks** (`[[...]]`), not markdown links; cross-reference via `related:` frontmatter.

### lesson (`lessons/`)

```markdown
---
tags: [postmortem, <area>, <area>/<subarea>, gotcha, ...]
date: YYYY-MM-DD
project: <project>
area: <repo-or-component>
severity: <low|medium|high>
related: [[<other-lesson-slug>]]
---

# <Short imperative title>

## TL;DR
One or two sentences. The takeaway, not the story.

## What happened
The incident with concrete evidence — failing code, command run, visible symptom.

## Root cause
*Why* it happened, not just *what*. This is the part that survives.

## The rule
The going-forward fix or guideline. Actionable. Code snippets welcome.

## How to detect / verify
What to check so it doesn't recur.
```

Always include `postmortem` for incidents, `gotcha` for non-obvious behaviors. Multiple distinct lessons in one session → separate files.

### decision (`decisions/`)

```markdown
---
tags: [decision, adr, <area>, <area>/<subarea>]
date: YYYY-MM-DD
project: <project>
area: <repo-or-component>
status: <proposed | accepted | superseded | deprecated>
supersedes: [[<slug>]]      # optional
superseded-by: [[<slug>]]   # optional, fill in later
related: [[<other-slug>]]
---

# <Short imperative title — the decision itself>

## TL;DR
One sentence: what we decided.

## Context
The situation that required a decision. Constraints / pressures / requirements.

## Decision
What we chose, stated as a directive. Include scope limits.

## Alternatives considered
Each with one or two lines on why rejected. At least 2 — no real alternative means it probably isn't a decision worth recording.

## Consequences
What this enables. What it forecloses. Follow-up work implied. Debt accepted.
```

If the project uses ADR numbering (`decisions/NNNN-*.md` exists), continue the sequence instead of date-prefixing. If the conversation hasn't actually settled, don't write — or write with `status: proposed` and flag it.

### preference (`preferences/`)

Ask whether the preference is **project-scoped** (default) or **global**. In a multi-vault setup also apply the ownership test: *personal working style* → the personal vault, always; *team convention* → the team vault.

```markdown
---
tags: [preference, <area>, <area>/<subarea>]
date: YYYY-MM-DD
project: <project>
area: <repo-or-component>
scope: <project | global>
related: [[<other-slug>]]
---

# <Short imperative title — the preference itself>

## TL;DR
One sentence: the preference, stated as a directive.

## Why
The motivation. Without the why, future-you second-guesses the rule.

## How to apply
When does this kick in? What does it look like in practice?

## When NOT to apply
The edge cases. Every preference has limits.
```

**Dual-write to Claude memory:** project scope → `~/.claude/projects/<encoded-cwd>/memory/feedback_<slug>.md` (`type: feedback` frontmatter; add a line to `MEMORY.md`); global scope → a new absolute, unambiguous section in `~/.claude/CLAUDE.md`. Never `#postmortem` — preferences are forward-looking. Check for conflicting existing preferences first; update rather than contradict.

### reference (`references/`)

Kinds: `dashboard | repo | person | doc | tool | channel | vendor`. Ask if unclear.

```markdown
---
tags: [reference, external, <kind>, <area>]
date: YYYY-MM-DD
project: <project>
area: <repo-or-component>
kind: <kind>
url: <https://… or n/a>
owner: <person or team, if known>
related: [[<other-slug>]]
---

# <Resource name — short>

## TL;DR
What this is and when to consult it.

## Where
URL, repo path, channel, email — whatever locator gets you there.

## What it's for
What you can find / do here that you can't elsewhere.

## When to consult
The trigger conditions.

## Owner / contact
Who owns it or knows its quirks. For person-kind, the person *is* the resource.

## Notes
Quirks, access requirements, login flow.
```

References are for things *outside* the codebase, and only load-bearing ones. Check `references/` for duplicates; update instead.

### glossary (`glossary/`)

The term is **required** — if missing from `$ARGUMENTS`, ask. Slug = lowercased term, non-alphanumeric → hyphens (`ISO/IEC 7810 ID-1` → `iso-iec-7810-id-1`). No date prefix.

```markdown
---
tags: [glossary, vocabulary, <area>]
date: YYYY-MM-DD
project: <project>
area: <repo-or-component>
term: <the term, as the user uses it>
aliases: [<other spellings, synonyms, expansions>]
see-also: [[<related-term-slug>]]
---

# <Term>

## Definition
The shortest accurate definition. Start with what it *means*, not its history.

## In context
How the term shows up in the project. Concrete examples welcome.

## Standard / source
External standard (ISO, RFC, vendor doc) — cite it. Otherwise "internal" + origin.

## Don't confuse with
Related terms that are subtly different, with the distinction stated.
```

Add `#standard` if from an external standard. If the term exists in `glossary/`, update it — surface the existing definition first.

## Step 3 — Link from next.md

`next.md` lives in the resolved vault's `journal/` zone (excluded from ingestion). Add one line under the category's section at the **top** of the file, sections in this order (create only sections that have entries):

```markdown
## Lessons
- [[<YYYY-MM-DD>-<slug>|<short title>]] — #tag1 #tag2
## Decisions
- [[<slug>|<short title>]] — <status> · #tag1 #tag2
## Preferences
- [[<slug>|<short title>]] — <scope> · #tag1 #tag2
## References
- [[<slug>|<resource name>]] — <kind> · #tag1 #tag2
## Glossary
- [[<slug>|<Term>]] — <one-line definition>
```

Always **bare-slug** wikilinks — no folder prefix; Obsidian resolves by basename.

## Step 4 — Confirm

Report the vault + file path written, tags used, the `next.md` line added, and (preferences) the memory write. Keep it tight.

## Skip / refuse — all categories

- No real takeaway → say so; don't fabricate to satisfy the command.
- Wrong category for the content → say which fits and use that spec instead (confirm if the switch is significant).
- Routine task completion, code that lives in the repo, or ephemeral session state → not vault material.
