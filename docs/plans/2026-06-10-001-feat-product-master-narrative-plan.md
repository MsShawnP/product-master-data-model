---
title: "feat: Build product-master-data-model portfolio page"
created: 2026-06-10
status: active
origin: brief_product_master_data_model.md
tier: medium
---

# feat: Build product-master-data-model portfolio page

## Problem Frame

A $15M–$25M specialty food brand has product data in five places — ERP item master, 1WorldSync, co-packer specs, retailer portals, Shopify — and no documented model of how a product relates to its GTINs, case configurations, and the attribute set each retailer demands. Every retailer onboarding re-derives this from scratch. Every new hire learns it by tribal knowledge.

The Cinderhaven Data Platform's `dim_products` model is the canonical source of truth for product fields at the case level — but it has no packaging hierarchy (each/inner/case/pallet), no per-level GTIN assignment, no retailer attribute mapping. CHP-0009's `case_weight_lbs` and dimension fields are **NULL** in the live platform — a concrete example of what breaks without the model this piece documents.

This portfolio piece demonstrates data architecture as a deliverable: not a diagnostic, not a quantification, but the model itself — documented, contracted, and proven to run. It is the hub the Cinderhaven diagnostic spokes gesture at.

**Primary audience:** COO / ops lead.
**Secondary audience:** IT lead / ERP admin / fractional CTO — the technical validator.
**Distribution:** COO forwards the ERD page to IT: "Is this what we should have?"

---

## Scope Boundaries

### In scope

- Narrative web page at `master.lailarallc.com`: three-part structure (Hook → Proof → Evidence)
- Annotated ERD: Mermaid view (annotated, readable), D3 interactive view (click-to-highlight), downloadable SVG
- Postgres DDL files: proposed schema for `dim_products` plus the four missing satellites
- dbt docs site: generated from the existing Cinderhaven platform, deployed separately
- Cross-links from this page to Dimension & Weight Integrity, PDHA, and Item Setup Pre-flight
- Canonical figures from CINDERHAVEN_CANONICAL.md: use **$458K/yr** (not $461K — brief has superseded figure)

### Out of scope

- No new dbt models running on the live platform
- No new synthetic data generation
- No regulatory attributes (allergen/nutritional) — explicitly flagged as Recall Blast Radius territory
- No PIM tool comparison or selection content
- No lot/batch entities (that is Recall Blast Radius)
- No DDL "starter kit" lead magnet — DDL stays repo-only for now

### Deferred to Follow-Up Work

- Downloadable DDL starter kit as a lead magnet (brief §11, open question #3)
- Regulatory attribute entities once Recall Blast Radius piece is shipped
- GS1 Sunrise 2027 callout section — brief mentions it as forward-looking context; can add post-ship as a note
- Column-level lineage in dbt docs (requires datafold or dbt-column-lineage; model-level lineage is sufficient for this piece)

---

## Key Technical Decisions

**1. Astro for the narrative page (not Vite/React SPA)**
The `channel-profitability-analysis` project is a working Astro 5.9.0 + MDX + D3 + Cloudflare Pages template. The product-master piece has the same structure: distinct named sections, prose + embedded interactive visualization, static output. Start from that template. The Vite/React SPA pattern (dimension-weight-integrity) has no section-based structure and no D3 — it is the wrong template for this piece.
*(see origin: brief_product_master_data_model.md §4)*

**2. Astro version: use 5.9.0 (matching the template) not 6.x**
Astro 6.4.5 is current but introduces a breaking Content Layer API change and a known static-output failure when the Cloudflare adapter is installed (issue #15650). For a new portfolio piece, start from the working template version (5.9.0) to avoid migration friction. Upgrade once the template project upgrades.

**3. ERD: three-view toggle (Mermaid, D3, SVG download)**
Per user decision: all three formats rendered in the page with a toggle so the reader can pick their view. Mermaid is the "annotated / readable" view; D3 is the "interactive" view; SVG download is a pre-rendered file in `site/public/downloads/`. The toggle is implemented with a plain Astro `<script>` tag — no React needed.

**4. Mermaid in Astro: `astro-mermaid` (client-side, not `rehype-mermaid`)**
`rehype-mermaid` requires Playwright/Chromium and has documented rendering divergence on Windows. `astro-mermaid@2.0.2` runs client-side with no headless browser dependency and is the correct choice for Windows development. For production, pre-render the Mermaid ERD to SVG using `mmdc` (Mermaid CLI) once the diagram is final and embed it as a static image — this sidesteps the 760KB client-side JS cost and satisfies the print requirement.
**Do not use `rehype-mermaid` in the Windows dev environment.**

**5. D3 ERD: `@dagrejs/dagre` for layout + D3 v7 for rendering**
`dagre-d3` is abandoned (last release 2017, D3 v4 only). Use `@dagrejs/dagre` (v3.0.0, Nov 2025) as the layout engine to compute node positions, then render with D3 v7 SVG. Force-directed layout is wrong for an ERD — use dagre's hierarchical layout for a deterministic diagram.
**Do not use `dagre-d3`.**

**6. D3 as plain Astro `<script>` (not a React island)**
Astro processes `<script>` tags as bundled ES modules with npm import resolution. D3 and `@dagrejs/dagre` can be imported directly without a framework component. No `client:load` directive needed. This keeps zero framework dependencies for the ERD component.

**7. No Cloudflare adapter for the narrative site**
Astro static output does not need the `@astrojs/cloudflare` adapter. The adapter is only for SSR. Installing it in static mode causes a known failure (missing `dist/server/wrangler.json`). Deploy with `npx wrangler pages deploy ./dist --project-name=product-master-data-model`.
**Do not install `@astrojs/cloudflare`.**

**8. dbt docs = separate Cloudflare Pages deployment**
Generate from the Cinderhaven platform (`dbt docs generate` in the platform repo), deploy the `target/` folder as its own Cloudflare Pages project (e.g., `dbt-docs.lailarallc.com`). The narrative page links to it. This keeps the platform's docs separate from the narrative site.

**9. GS1 indicator digits: no semantic mapping**
GS1 explicitly states that indicator digits 1–8 have no standardized meaning. The ERD and narrative must not present a mapping like "indicator 1 = inner pack, indicator 2 = case" as if it were a GS1 standard. Show an example assignment (a brand chose indicator 1 for their 12-count case) while making clear it is brand-specific.

**10. Canonical figure: $458K/yr (not $461K)**
`CINDERHAVEN_CANONICAL.md` (last verified 2026-06-08) locks this at $458K. The brief's $461K is superseded. All narrative prose and the margin math section use $458K. Run `check_canonical.py` (in the Cinderhaven platform at `scripts/check_canonical.py`) before publishing any figure.

---

## High-Level Technical Design

*This illustrates the intended architecture and is directional guidance for review, not implementation specification.*

```
┌─────────────────────────────────────────────────────────┐
│  product-master-data-model repo                          │
│                                                          │
│  site/            Astro 5.9 static narrative page        │
│  ├── src/pages/   One page: index.astro                  │
│  ├── src/components/  ERD toggle, section components     │
│  └── public/downloads/erd.svg  pre-rendered SVG          │
│                                                          │
│  sql/             Proposed Postgres DDL (schema spec)    │
│  ├── dim_products_extended.sql   anchor + new columns    │
│  ├── dim_packaging_levels.sql                            │
│  ├── dim_gtin_assignments.sql                            │
│  └── dim_retailer_attributes.sql                         │
└────────────────────┬────────────────────────────────────┘
                     │ deploys to
                     ▼
         master.lailarallc.com (Cloudflare Pages)

┌─────────────────────────────────────────────────────────┐
│  cinderhaven-data-platform (existing, read-only)         │
│  └── dbt docs generate → target/                         │
└────────────────────┬────────────────────────────────────┘
                     │ deploys to
                     ▼
         dbt-docs.lailarallc.com (Cloudflare Pages)
         (linked from Part 3 of the narrative)
```

**Page structure (three parts):**

```
index.astro
├── Part 1 — The Hook
│   ├── Headline: "Walmart, Costco, and UNFI are not asking
│   │   about the same product."
│   └── ThreeRetailerComparison component
│       (side-by-side item setup fields, GTIN level highlighted)
│
├── Part 2 — The Proof
│   ├── GTIN hierarchy walkthrough: CHP-0009 each→inner→case→pallet
│   ├── ERDToggle component (Mermaid | D3 | SVG download)
│   └── Entity table: each entity + "what breaks without it"
│
└── Part 3 — The Evidence
    ├── Live dbt docs link (lineage + column docs)
    ├── DDL download link (repo link to sql/)
    ├── Canonical figures ($458K/yr, margin math)
    └── Cross-links to Dimension & Weight, PDHA, Pre-flight
```

---

## Output Structure

```
product-master-data-model/
├── site/
│   ├── src/
│   │   ├── pages/
│   │   │   └── index.astro
│   │   ├── components/
│   │   │   ├── ThreeRetailerComparison.astro
│   │   │   ├── ERDToggle.astro
│   │   │   ├── ERDMermaid.astro
│   │   │   ├── ERDInteractive.astro    (D3 component)
│   │   │   ├── EntityTable.astro
│   │   │   └── MarginMath.astro
│   │   └── layouts/
│   │       └── NarrativeLayout.astro
│   ├── public/
│   │   └── downloads/
│   │       └── erd.svg
│   ├── astro.config.mjs
│   ├── package.json
│   └── tsconfig.json
├── sql/
│   ├── dim_products_extended.sql
│   ├── dim_packaging_levels.sql
│   ├── dim_gtin_assignments.sql
│   └── dim_retailer_attributes.sql
└── docs/
    └── plans/
        └── 2026-06-10-001-feat-product-master-narrative-plan.md
```

---

## Implementation Units

### U1. Scaffold the Astro site in `site/`

**Goal:** Create a working Astro 5.9.0 project in `site/` with the Lailara design system tokens, fonts, and layout — ready for section components.

**Requirements:** §4 deliverables (narrative walkthrough), §6 Skills Demonstrated (the reader must reach the model)

**Dependencies:** None

**Files:**
- `site/package.json`
- `site/astro.config.mjs`
- `site/tsconfig.json`
- `site/src/layouts/NarrativeLayout.astro`
- `site/src/pages/index.astro` (skeleton, three-part structure)
- `site/.gitignore` (node_modules/, dist/)

**Approach:**
- Copy `astro.config.mjs`, `package.json`, `tsconfig.json` from `channel-profitability-analysis` and adapt (remove MDX integration if not needed; remove React integration since the ERD uses plain Astro `<script>` not React islands)
- Dependencies to include: `astro@5.9.0`, `@fontsource/playfair-display`, `@fontsource/source-sans-3`, `astro-mermaid`, `d3`, `@dagrejs/dagre`
- `NarrativeLayout.astro` sets the `<head>` (fonts, meta, og:image), wraps content in the Canvas background (`#f5f3ee`), and includes the print stylesheet
- `index.astro` imports the layout and has three named `<section>` elements with placeholder content
- Fonts: load via `@fontsource` packages, not Google Fonts CDN (established pattern from dimension-weight-integrity)
- No Cloudflare adapter — static output only
- Verify `npm run build` produces a `dist/` folder with `index.html`

**Patterns to follow:**
- `channel-profitability-analysis/astro.config.mjs` — configuration shape
- `channel-profitability-analysis/src/layouts/NarrativeLayout.astro` — layout structure
- `dimension-weight-integrity/frontend/src/main.tsx` — font loading via `@fontsource`

**Test scenarios:**
- `npm run dev` starts without errors
- `npm run build` produces `dist/index.html`
- Page loads in browser with Canvas background (`#f5f3ee`) and correct fonts (Playfair Display serif for headings, Source Sans 3 for body)
- No console errors on load
- `@media print` shows white background, hides interactive controls

**Verification:** `npm run build` exits 0; `dist/index.html` exists; page renders in browser with correct background color and typography.

---

### U2. Author the Postgres DDL schema

**Goal:** Write the four proposed SQL files that define what the product master *should* have — the proposed schema that the ERD visualizes and the narrative describes. These are repo artifacts (not running against the live platform).

**Requirements:** §4 deliverables (DDL + contract files), §3 Part 2 (the proof — annotated ERD and documented model)

**Dependencies:** None (can run in parallel with U1)

**Files:**
- `sql/dim_products_extended.sql` — the existing `dim_products` anchor, with the packaging columns that are currently NULL or missing, and a note on each gap
- `sql/dim_packaging_levels.sql` — proposed table: sku, packaging_level (each/inner/case/pallet), quantity_per_level, level_weight_lbs, level_length_in, level_width_in, level_height_in
- `sql/dim_gtin_assignments.sql` — proposed table: sku, packaging_level, gtin (text), gtin_type (GTIN-12/GTIN-14/SSCC), indicator_digit (nullable, for GTIN-14 only)
- `sql/dim_retailer_attributes.sql` — proposed table: sku, retailer, attribute_key, attribute_value, attribute_source, last_synced

**Approach:**
- `dim_products_extended.sql`: Comment each NULL/missing column in the existing schema. Include a `-- MISSING` inline comment on `gtin14`, `upc`, and all dimension columns that CHP-0009 currently has as NULL. This file is documentary — it shows the existing contract plus what's absent.
- `dim_packaging_levels.sql`: Composite PK on `(sku, packaging_level)`. `packaging_level` uses a CHECK constraint: `IN ('each', 'inner', 'case', 'pallet')`. No indicator digit here — that belongs in `dim_gtin_assignments`.
- `dim_gtin_assignments.sql`: `gtin_type` CHECK constraint: `IN ('GTIN-12', 'GTIN-13', 'GTIN-14', 'SSCC')`. `indicator_digit` is nullable and INTEGER (valid values 1–8 for GTIN-14, NULL for others). Add a comment: "GS1 indicator digits 1–8 carry no standardized meaning; value is brand-assigned."
- `dim_retailer_attributes.sql`: Composite PK on `(sku, retailer, attribute_key)`. `retailer` matches the Cinderhaven retailer set (Walmart, Costco, Whole Foods, Sprouts, Kroger, Regional Group, UNFI, KeHE, DTC).
- All files: include a header comment block with the entity description and "what breaks without this entity" — this text feeds the ERD callouts and the entity table in Part 2.

**Patterns to follow:**
- `dim_products.sql` (Cinderhaven platform) — existing column conventions and DDL style
- `schema.yml` (dimension-weight-integrity dbt project) — how contracts are documented

**Test scenarios:**
- Each file is valid SQL (no syntax errors when run through `psql --set ON_ERROR_STOP=1 -f <file>` against a local Postgres)
- `dim_products_extended.sql` has inline `-- MISSING` comments on the NULL columns
- `dim_gtin_assignments.sql` has the indicator digit comment
- All four files together define a consistent schema (FK references are consistent, retailer list matches CINDERHAVEN_CANONICAL.md)

**Verification:** Files exist; each is valid SQL; `dim_gtin_assignments.sql` contains the GS1 disclaimer comment; all retailer names match CINDERHAVEN_CANONICAL.md.

---

### U3. Build Part 1 — The Hook

**Goal:** The hook section: "Walmart, Costco, and UNFI are not asking about the same product." A side-by-side comparison of three retailer item setup forms showing that the same CHP-0009 maps to different GTIN levels, with the problem stated plainly.

**Requirements:** §3 Part 1 (the hook), §7 (LinkedIn image — the side-by-side comparison is the screenshot piece)

**Dependencies:** U1 (Astro scaffold)

**Files:**
- `site/src/components/ThreeRetailerComparison.astro`
- `site/src/pages/index.astro` (Part 1 section content added)

**Approach:**
- `ThreeRetailerComparison.astro`: Three columns, one per retailer (Walmart, Costco, UNFI). Each column shows a stylized item setup form card: retailer name, the fields they require for CHP-0009, and the GTIN level that field keys on. Fields that map to different levels are highlighted with a colored badge (Lailara Chicago navy for "each-level", Hong Kong teal for "case-level", Singapore orange for "missing/warning").
- The reader should see: Walmart keys item setup on the each (GTIN-12); Costco's selling unit is the case (GTIN-14 with consumer-unit GTIN); UNFI requires the case hierarchy plus EDI 832 item setup. Same jar. Three different definitions.
- Data is hardcoded in the component (no API, no JSON import). CHP-0009 values from seed: gtin14=`00850074000090`, upc=`0074000090`, case_pack_qty=24, msrp=$12.50.
- Part 1 prose (inside `index.astro`): one paragraph framing sentence, the component, then 2-3 sentences stating the consequence: "Your flat spreadsheet cannot represent this. These three forms are asking about three different products. They're all the same jar of marinara."
- Style: Economist voice (brief §10, LinkedIn hook text).
- The three-column layout must collapse gracefully on mobile (< 640px) to stacked cards.

**Patterns to follow:**
- Lailara Design System: Chicago navy `#1f2e7a` for active/anchor, HK teal `#158f75` for positive data, SG `#ee8a2a` for warnings
- `dimension-weight-integrity` chapter cards — stylized data display pattern

**Test scenarios:**
- Component renders three columns on desktop
- On mobile (< 640px viewport), columns stack vertically
- CHP-0009 GTIN values match the seed data (`upc=0074000090`, `case_pack_qty=24`)
- GTIN level badges appear and are correctly colored
- Component is visually screenshot-ready (clean enough for the LinkedIn post)
- No console errors

**Verification:** Component renders correctly at desktop and mobile widths; GTIN values match seed; color-coded badges present.

---

### U4. Build the annotated ERD — three-view toggle

**Goal:** The ERD component showing the proposed product master schema: Mermaid annotated view, D3 interactive view, and downloadable SVG. With a toggle so the reader can switch.

**Requirements:** §3 Part 2 (annotated ERD), §4 (interactive D3/SVG deliverable)

**Dependencies:** U1 (Astro scaffold), U2 (DDL defines the entities)

**Files:**
- `site/src/components/ERDToggle.astro` (toggle UI + view switcher script)
- `site/src/components/ERDMermaid.astro` (Mermaid `erDiagram` block)
- `site/src/components/ERDInteractive.astro` (D3 + dagre ERD)
- `site/public/downloads/erd.svg` (pre-rendered SVG, generated once and committed)

**Approach:**

**Entities in the ERD (6 nodes):**
1. `dim_products` — anchor (existing, Cincerhaven canonical)
2. `dim_packaging_levels` — each/inner/case/pallet per SKU
3. `dim_gtin_assignments` — GTIN per packaging level
4. `dim_retailer_attributes` — retailer-specific attribute set
5. `syndication_targets` — GDSN/1WorldSync as consumers (not sources)
6. `retailer_portals` — Walmart, Costco, UNFI, etc. as attribute consumers

**Mermaid view (`ERDMermaid.astro`):**
- Use `astro-mermaid` integration; render `erDiagram` with attribute-level annotations
- Each entity gets its key columns listed with type + PK/FK markers
- Relationship labels use the Lailara voice: `dim_products ||--o{ dim_packaging_levels : "has packaging levels"`
- Add `erDiagram` attribute comments (double-quoted) as the "what breaks without this entity" callout: `string gtin "NULL in 42% of SKUs without this entity"`
- Do NOT map indicator digits 1–8 to semantic meanings

**D3 interactive view (`ERDInteractive.astro`):**
- Import `d3` and `@dagrejs/dagre` via plain Astro `<script>` tag (no React)
- Use dagre for deterministic hierarchical layout; compute node positions; render with D3 v7 SVG
- Entity nodes: rounded rectangles, Lailara Canvas background with Chicago navy header bar, entity name in Playfair Display serif, key columns listed in Source Sans 3
- Relationship edges: directed arrows with relationship label text
- Interaction: click an entity to pin it (highlight its edges, dim others to 0.3 opacity); click again to dismiss. `opacity 200ms ease-out` transition per design system.
- Dark callout card on pin (background `#1a1a1a`, white text): entity name, key columns, "what breaks without it" one-liner
- Layout direction: top-down (brand → product → item levels flow downward)

**Toggle (`ERDToggle.astro`):**
```
[Annotated] [Interactive]  ↓ Download SVG
```
- Toggle switches between `<div id="view-mermaid">` and `<div id="view-d3">` using `hidden` attribute
- Download SVG link points to `/downloads/erd.svg`; uses `download` attribute
- Lazy-init D3 on first reveal (to avoid rendering into a hidden element)
- Active button state: Chicago navy background, white text; inactive: border only

**Downloadable SVG (`site/public/downloads/erd.svg`):**
- Generate once: after the D3 view is rendering correctly, serialize the SVG DOM node (`new XMLSerializer().serializeToString(svgElement)`), save to a file, and commit it
- This is the print-quality artifact — no interactive JS, clean vector

**Patterns to follow:**
- Lailara Design System interaction pattern: click-to-pin, not hover tooltips; `opacity 200ms ease-out`
- Dark callout card spec: `#1a1a1a` background, `rgba(255,255,255,0.12)` internal borders
- D3 sub-module imports from `channel-profitability-analysis/package.json` (selective, not the full bundle)

**Test scenarios:**
- Both views render without console errors
- Toggle switches between Mermaid and D3 views correctly
- D3 view: clicking an entity pins it; clicking again unpins
- D3 view: non-selected entities/edges dim to ≈0.3 opacity with 200ms transition
- Dark callout card appears on pin with correct entity info
- Download link triggers SVG download (not in-tab preview)
- On mobile (< 640px): D3 view is scrollable/zoomable or shows a "best viewed on desktop" message rather than breaking
- `erDiagram` Mermaid view renders all 6 entities and shows relationships

**Verification:** Both toggle views render; pin/dim interaction works; download link triggers file download; SVG file exists in `site/public/downloads/`.

---

### U5. Build Part 2 — The Proof

**Goal:** The main narrative section: CHP-0009 walks through the hierarchy (each → inner → case → pallet), the ERD is embedded, and each entity gets a "what breaks without it" callout.

**Requirements:** §3 Part 2 (the proof), §5 Skills Demonstrated (GS1 fluency, dimensional modeling)

**Dependencies:** U3 (Part 1 complete for page context), U4 (ERD component)

**Files:**
- `site/src/components/EntityTable.astro`
- `site/src/components/GTINHierarchy.astro` (the CHP-0009 walkthrough visual)
- `site/src/pages/index.astro` (Part 2 section content)

**Approach:**

**GTIN hierarchy walkthrough (`GTINHierarchy.astro`):**
- A vertical or horizontal flow showing CHP-0009 at each packaging level
- Each level card: level name (Each / Inner / Case / Pallet), quantity, GTIN value (for each and case — real values from the seed), status badge
- Each-level: `upc=0074000090` (GTIN-12), 1 unit, $12.50 MSRP
- Case-level: `gtin14=00850074000090` (GTIN-14), 24 units, dimensions **NULL** — show this as a red/orange badge: "Missing — the problem this model solves"
- Inner: no GTIN assigned; show as "Not assigned" (grey)
- Pallet: SSCC (not a GTIN), "Logistics identifier — not a trade item GTIN"
- Include the GS1 indicator digit note: the first digit of the GTIN-14 (`0` in `00850074000090`) is a GS1-assigned zero-padding convention used by this brand, not a semantic indicator. Do not label it as "case indicator."

**ERD embed:** Import `ERDToggle.astro` directly in the Part 2 section.

**Entity table (`EntityTable.astro`):**
- Four-column table: Entity | Key Columns | Who Uses It | What Breaks Without It
- 6 rows (one per ERD entity). Written in Economist voice — direct, concrete.
- "What Breaks Without It" column ties each entity back to a shipped Cinderhaven diagnostic piece (with a hyperlink)
- Example row: `dim_packaging_levels | sku, packaging_level, quantity_per_level, dimensions | Retailer item setup forms, 1WorldSync sync | Item setup forms filled by archaeology; dimension fields stay NULL (as in CHP-0009 today)`

**Part 2 prose:**
- Lead with the CHP-0009 hierarchy walkthrough visual
- Follow with: "Here is the model that prevents this." Brief paragraph on the structure, then the ERD toggle.
- Follow ERD with the entity table.
- Each entity's "what breaks" callout cross-links to the relevant shipped piece.

**GS1 accuracy requirements:**
- Indicator digits 1–8 have no standardized meaning — show the brand's assignment, not a GS1 definition
- Costco selling unit = the bulk carton that has its own GTIN-12 as a consumer unit (not a GTIN-14 case)
- SSCC ≠ GTIN: pallet carries an SSCC for logistics tracking, a GTIN-14 only if it is a standardized orderable trade unit
- Flag Costco hierarchy specifics with: "Verify against Costco's current supplier compliance guide before publishing this page."

**Patterns to follow:**
- Economist voice: sober, declarative, no marketing language
- Lailara Design System: semantic status colors for the NULL/missing badge (Fail: `#fde8e7` / `#7a0906`)
- `dimension-weight-integrity` chapter prose rhythm — short paragraphs, one claim per paragraph

**Test scenarios:**
- GTIN hierarchy walkthrough shows correct CHP-0009 values (`upc=0074000090`, `gtin14=00850074000090`, `case_pack_qty=24`)
- NULL dimension fields show as a red/warning badge
- Entity table has 6 rows; each "what breaks" cell links to a real shipped piece
- ERD toggle is embedded and functional within Part 2
- Prose contains no marketing language, no hedging
- GS1 indicator digit note is present on the case-level GTIN card

**Verification:** GTIN values correct; NULL badge present; entity table has 6 rows with cross-links; ERD embedded and functional.

---

### U6. Build Part 3 — The Evidence, and deploy dbt docs

**Goal:** The evidence section proving the model runs: canonical figures, the dbt docs site link, the DDL download, and the drift-guard script reference. Plus: generate dbt docs from the Cinderhaven platform and deploy them as a static site.

**Requirements:** §3 Part 3 (the evidence), §4 (dbt docs site deliverable)

**Dependencies:** U5 (Part 2 complete; narrative flows Part 1 → 2 → 3)

**Files:**
- `site/src/components/MarginMath.astro`
- `site/src/pages/index.astro` (Part 3 section content)
- *(dbt docs generated externally in the Cinderhaven platform repo)*

**Approach:**

**dbt docs generation (in the Cinderhaven platform repo, not this repo):**
- Run `dbt docs generate` in the Cinderhaven platform
- This produces `target/index.html`, `target/manifest.json`, `target/catalog.json`
- Deploy via `npx wrangler pages deploy ./target --project-name=cinderhaven-dbt-docs`
- Assign subdomain (e.g., `dbt-docs.lailarallc.com`) in Cloudflare Pages dashboard
- Verify the lineage graph shows `dim_products` and its dependencies before linking

**Part 3 prose and components:**
- "This isn't a whiteboard diagram — it runs." Lead sentence.
- Live dbt docs link: `https://dbt-docs.lailarallc.com` — hyperlinked with label "Browse the lineage →"
- DDL download: link to the `sql/` directory in the GitHub repo (public browse, not a zip download — repo is private, so link to the files page when/if repo goes public; for now, omit the external link and reference the repo path)
- Drift-guard reference: one sentence — "The platform includes a canonical drift-guard script (`check_canonical.py`) that validates all published figures against live Postgres data before any release."
- `MarginMath.astro`: the "$458K/yr" callout. Brief sentence: "The Product Data Health Audit established **$458K/yr** in chargeback cost attributable to data-quality defects at Cinderhaven's scale." Link to PDHA piece. Add the onboarding math: "Each retailer launch delayed by item-setup rejection ≈ 4–8 weeks of shelf revenue deferred." Reference Cost of Saying Yes piece for cash-flow framing.
- Cross-links section: three chips/tags — "Built on: Dimension & Weight Integrity", "Built on: Product Data Health Audit", "Feeds: Item Setup Form Pre-flight"
- Footnote: canonical figures as of `CINDERHAVEN_CANONICAL.md` last verified 2026-06-08.

**Canonical figure accuracy check:**
Before writing final prose: run `check_canonical.py` in the Cinderhaven platform repo to confirm $458K, 50 SKUs, 6 retailers, 3 distributors, $32.8M scan revenue. Use only approved phrasings.

**Patterns to follow:**
- `check_canonical.py --emit` for current approved figures
- Lailara Design System dark callout card for the "$458K/yr" stat
- Cross-link chip style from lailara-website or dimension-weight-integrity footer

**Test scenarios:**
- dbt docs site loads at its Cloudflare Pages URL before the narrative links to it
- dbt docs lineage graph shows `dim_products`
- MarginMath component shows $458K (not $461K)
- Cross-link chips link to real published pages (not 404s)
- "canonical figures as of" footnote is present
- `check_canonical.py` passes before publish

**Verification:** dbt docs deployed and accessible; $458K figure in narrative; cross-links not 404; `check_canonical.py` passes.

---

### U7. Deploy narrative site to master.lailarallc.com

**Goal:** The Astro narrative page is live at `master.lailarallc.com`, passes the pre-ship checklist, and the health tracker is updated.

**Requirements:** §4 deployment spec, §10 tactical notes (verify GS1 terminology, cross-link aggressively)

**Dependencies:** U3, U4, U5, U6 (all sections complete)

**Files:**
- `site/package.json` — confirm build command is `npm run build`
- `site/astro.config.mjs` — confirm `output: 'static'`, no Cloudflare adapter

**Approach:**
- Final GS1 review before deploy: re-read all indicator digit references and Costco hierarchy claims. Verify each against the GS1 research findings. Flag anything that overstates GS1 standards as brand-specific assignments.
- Run `check_canonical.py` one final time.
- Run `npm run build` in `site/`; verify `dist/index.html` exists
- Deploy: `npx wrangler pages deploy ./dist --project-name=product-master-data-model`
- Cloudflare Pages dashboard: add custom domain `master.lailarallc.com`; point DNS CNAME to the `*.pages.dev` URL
- Verify: page loads at `master.lailarallc.com`, all three ERD views work, dbt docs link resolves, cross-links resolve, `@media print` hides interactive controls
- Update project-health.md: set `/ce:code-review` date
- Update PLAN.md: arc complete

**Test scenarios:**
- `npm run build` exits 0 with no warnings
- `dist/index.html` exists and is well-formed HTML
- Page loads at `master.lailarallc.com` with correct SSL
- All three ERD views functional (Mermaid renders, D3 interactive, SVG download triggers)
- dbt docs link resolves to deployed site
- All cross-links (Dimension & Weight, PDHA, Pre-flight) resolve
- Mobile layout (< 640px) renders without overflow or broken layout
- `@media print` hides toggle controls, shows static content
- No JS console errors
- Lighthouse accessibility score ≥ 90

**Verification:** Site live at `master.lailarallc.com`; all links resolve; ERD views functional; Lighthouse score ≥ 90.

---

## System-Wide Impact

| Surface | Impact |
|---|---|
| `master.lailarallc.com` | New subdomain — requires DNS configuration in Cloudflare |
| `dbt-docs.lailarallc.com` | New subdomain — requires Cloudflare Pages project + DNS |
| Lailara portfolio `/work` page | Add new "Architecture" grouping with this piece as anchor |
| Cinderhaven platform | Read-only: `dbt docs generate` run against it; `check_canonical.py` run for figures |
| CINDERHAVEN_CANONICAL.md | No changes — this piece cites it, does not modify it |

---

## Dependencies and Prerequisites

- Cinderhaven Data Platform must be accessible (Fly.io Postgres via `flyctl proxy`) for `dbt docs generate` and `check_canonical.py`
- `wrangler` authenticated and Cloudflare account has DNS control for `lailarallc.com`
- `node >= 18` for Astro 5.9.0 (Node 22 recommended; Node 18 is the minimum)
- GS1 indicator digit research is complete (done — see Key Technical Decisions §9)
- Costco hierarchy: verify against Costco's current supplier compliance guide before publishing that section

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| GS1 terminology error (indicator digits, Costco hierarchy) | Medium | High — piece will be read by practitioners who will notice | Pre-publish GS1 review; do not claim indicator digit semantics as GS1 standard; flag Costco claim for manual verification |
| D3/dagre ERD complexity overruns (ERD is harder to build than planned) | Medium | Medium — ERD can ship as Mermaid-only if D3 is stuck | ERD toggle design means Mermaid view is the fallback; D3 is additive |
| dbt docs `--static` flag bug (issue #11986 in dbt-core) | Low | Low — mitigated by using the folder deploy path | Use `wrangler pages deploy ./target` not `--static`; avoid the single-file path |
| `astro-mermaid` client-side JS (760KB) slows page load | Low | Low — single-page narrative, not a high-traffic app | Acceptable for a portfolio piece; pre-render to SVG as future optimization |
| Canonical figures drift between plan and publish date | Medium | Medium — published figures must match live Postgres | Run `check_canonical.py` immediately before publishing; do not hardcode figures in components |

---

## Deferred Implementation Notes

- The exact dagre layout parameters (node spacing, rank separation, graph direction) will be tuned during implementation once rendering starts — these are execution-time discoveries.
- The Mermaid `erDiagram` attribute comment truncation behavior varies by diagram complexity — exact annotation length for the "what breaks" text will be adjusted at render time.
- The DDL download link (U6) is repo-only for now; if the repo goes public, update the link to point to the GitHub browse URL.
- GS1 Sunrise 2027 forward-looking note: deferred per scope boundaries — add as a single footnote after the main ship if it adds value.
