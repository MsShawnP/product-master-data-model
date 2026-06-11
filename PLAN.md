# product-master-data-model — Current Work Plan

The current arc of work. Updated when the arc changes, not every
session. For session-by-session state, see HANDOFF.md.

---

## Goal

Ship `master.lailarallc.com` — a complete, live Lailara portfolio piece documenting the product master data model for specialty food brands, with a working Postgres schema, dbt contracts, annotated ERD (three views), and narrative web page.

## Why this arc, why now

This is the project. There is only one arc until it ships.

## Business question this arc answers

For a $15M–$25M specialty food brand with product data scattered across ERP, 1WorldSync, co-packer specs, retailer portals, and Shopify, what is the documented data model that makes a product master governable — one source of truth for every GTIN, packaging level, and retailer attribute requirement?

## Tasks

Full implementation plan: `docs/plans/2026-06-10-001-feat-product-master-narrative-plan.md`

- [x] **U1** — Scaffold Astro site in `site/` from `channel-profitability-analysis` (Astro 5.9.0 + MDX + D3 + Cloudflare Pages template)
- [x] **U2** — Write Postgres DDL: core product hierarchy tables + GS1 packaging tables + constraints
- [x] **U3** — Build Part 1 — The Hook (ThreeRetailerComparison component)
- [x] **U4** — Build annotated ERD — three-view toggle (ERDToggle, ERDMermaid, ERDInteractive D3+dagre)
- [x] **U5** — Author narrative web page: Hook → Proof → Evidence structure with inline ERD and dbt docs link
- [ ] **U6** — Wire Dagster asset graph: show `dim_products` → packaging hierarchy → retailer attribute fan-out
- [ ] **U7** — Deploy to Cloudflare Pages at `master.lailarallc.com`; dbt docs to subdomain

## Out of scope for this arc

- Regulatory/labeling attributes (nutrient density, allergens) — deferred
- Live Dagster pipeline execution against production data — diagram only
- DDL published to a running database — repo-only schema artifacts
- Retailer-specific attribute validation rules — structure only, not complete rule sets

## Definition of done for this arc

- [ ] `site/` builds without errors (`npm run build` exits 0)
- [ ] ERD renders in all three modes (Mermaid, D3, SVG download)
- [ ] dbt `schema.yml` contracts compile and tests pass
- [ ] Narrative page passes Lailara design system check (colors, typography, layout)
- [ ] Deployed and live at https://master.lailarallc.com
- [ ] Hero SKU CHP-0009 traces through every layer of the model

---

## Arc history

When an arc completes, archive its goal, completion date, and outcome
here. Then start a new arc above. Provides continuity without bloating
the active plan.

### [Date completed] — [Goal]
- Outcome: [what shipped or what was decided]
- Tag: [git tag if one was created]

---

## Improvement history

Track when this project was reviewed and improved via /improve.
Each entry records what was found, what was fixed, and when to
check again.

<!-- Entries are added by /improve — don't delete this section -->
