# product-master-data-model — Project Context for Claude

Tier: Medium

## What this project is

A Lailara LLC portfolio piece that documents the product master data model a specialty food brand should have — and proves it runs. The piece walks a reader through one SKU (CHP-0009) from brand → product → each → inner → case → pallet, shows the GTIN assigned at each packaging level, then fans that hierarchy out into the attribute sets Walmart, Costco, and UNFI each require. The deliverable is a narrative web page (Astro, deployed to `master.lailarallc.com`), an annotated interactive ERD (D3 or Mermaid), and a published dbt docs site showing lineage and column-level contracts. Every entity in the model maps to a shipped Cinderhaven diagnostic that proved what breaks without it.

**Business question this project answers:** For a $15M–$25M specialty food brand with product data in five places — ERP item master, 1WorldSync, co-packer specs, retailer portals, Shopify — what is the documented data model that makes a product master governable, with one source of truth for every GTIN, packaging level, and retailer attribute requirement?

## Stack and tools

- Primary language: SQL (Postgres DDL), Python (dbt, Dagster), JavaScript/Astro (narrative page)
- Key packages/libraries: dbt-core, dbt-postgres, Dagster, Astro
- Database: Postgres — the model itself (DDL + constraints)
- Entry point: `src/` for dbt models; `site/` for Astro narrative page
- Other tools: D3 or Mermaid (ERD), Cloudflare Pages (deployment), dbt docs (published lineage site)

## Project files

- CLAUDE.md (this file) — permanent rules and facts
- DECISIONS.md — durable choices and reasoning
- HANDOFF.md — current session state
- PLAN.md — current work arc
- FAILURES.md — things tried that didn't work

Read PLAN.md and HANDOFF.md at session start. DECISIONS.md and
FAILURES.md as relevant.

## Voice and standards

- Economist style: sober, declarative, data-forward
- Primary audience: COO / ops lead; secondary: IT lead / ERP admin / fractional CTO
- No marketing voice ("leverage," "synergy," "best-in-class," "unlock," "drive value")
- No hedging that softens a real finding
- Charts must be readable by non-data-scientist audiences
- Every data point must have a text label

## Cinderhaven constraints

- Hero SKU: CHP-0009 for all worked examples
- Canonical figures: 50 SKUs, 5 lines, 6 retailers, 3 distributors + DTC — match CINDERHAVEN_CANONICAL.md exactly
- Reuses the locked `dim_products` contract verbatim — do not modify it
- Zero new synthetic data — pure documentation of the existing platform

## GS1 rules (verify at build time, not from memory)

- Packaging levels: each (GTIN-12/13), inner pack, case (GTIN-14 with indicator digit), pallet (SSCC or GTIN-14)
- Indicator digit semantics for GTIN-14 differ from SSCC — flag if unsure
- Costco hierarchy: case is the saleable unit; Walmart item setup keys on the each — these divergences must be explicit in the ERD and narrative

## Rules

### Honesty and judgment

- Say "I don't know" or "I can't verify this" instead of guessing.
  This applies to industry context, technical claims, what code did,
  and anything else.
- Tell me what I need to hear, not what I want to hear. If a decision
  looks wrong, say so. If code I wrote has problems, say so. Honest
  assessment, not validation.
- If a rule in this file is too vague to verify whether you're
  following it, flag it for revision rather than guessing at compliance.

### Building and proposing

- No speculative abstractions. If something isn't needed right now,
  don't build it. Helper functions get added when called by real code,
  not in anticipation. Parameters get added when there's a second use
  case, not the first.
- When proposing a tool, library, or approach, present at least two
  alternatives with tradeoffs, even if one is clearly preferred. Do
  not propose a single solution and move on.
- Tie proposals back to the business question this project is
  answering. If you can't connect a proposal to that question, the
  proposal is probably fluff and should be reconsidered.
- Don't let this become a dbt tutorial — the audience is the COO; the
  dbt docs are an appendix.

### How to work the project

- Work in vertical slices, not horizontal phases. Build one deliverable
  end-to-end before moving to the next.
- When a feature is working, suggest a simple test to verify it stays
  working: "This works now — want to add a quick test so it doesn't
  break later?" Don't force testing, but make it easy to say yes.
- Do not start tasks outside the current PLAN.md arc without flagging
  it to the user first.
- Do not refactor unrelated code unprompted.
- Do not rename things unless asked.

### Git branching

- Before risky or experimental changes, suggest creating a branch:
  > "This is a significant change. Want to work on a branch so we
  > can easily undo it if it doesn't work out?"
- Keep it simple: `git checkout -b experiment/short-description`
  before the change, merge back to main if it works.

### Scope creep detection

- Periodically check whether the current work matches PLAN.md.
  If something not in the plan has been running for 15+ minutes, flag it.
- Also flag if PLAN.md tasks are accumulating faster than they're completing.

## Working with PLAN.md

PLAN.md defines the current arc of work. Read it at session start.

- Mark tasks complete as they're finished, in the same commit as the work
- If a task is wrong-sized, in the wrong order, or no longer relevant,
  flag it rather than silently restructuring
- "Out of scope" items are decisions, not suggestions — do not pull
  them into the current arc without explicit user approval

## Session reminders

### Reminding the user to /log

Prompt the user to run /log when:
- A meaningful change just landed (file written, bug fixed, feature added, decision made)
- A natural pause point is reached
- Roughly 30-45 minutes have passed since the last /log and real work has happened

Format as a clearly separated note. One suggestion per trigger.

### Reminding the user to /wrap

Prompt the user to run /wrap when:
- Context usage crosses 65%
- The user says anything that suggests they're stopping
- A natural milestone is reached
- 90+ minutes have passed and work is winding down

### Session start protocol

1. Read CLAUDE.md, PLAN.md, and HANDOFF.md
2. If HANDOFF.md's most recent entry is more than 24 hours old AND
   there are uncommitted changes, flag this
3. Briefly state the starting point from HANDOFF.md so the user confirms you're caught up
4. Confirm the current PLAN.md arc is still active
5. Check Improvement History in PLAN.md — flag if overdue
6. Remind: "type / to see your commands"

## Defaults

- Default to flagging gaps rather than filling with plausible-sounding but unverified content
- Default to short responses unless the task is substantive
- Default to asking before promoting a log entry to a DECISIONS.md entry
- Default to answering, not offering to answer

Never write secrets, tokens, or passwords into tracked files, READMEs, or commit messages — use environment variables and secret stores only.
