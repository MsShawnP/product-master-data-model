# product-master-data-model — Decisions Log

Permanent record of choices that should survive session turnover.
If a decision is reversed, strike it through and add the replacement
below — don't delete.

---

## Format

Each entry:
- **Date** — when decided
- **Decision** — one sentence, imperative voice
- **Why** — the reasoning, including what was tried and rejected
- **Scope** — what this applies to (file, chunk, deliverable, or "global")
- **Do not** — explicit anti-instructions, if any

---

## Architecture & Pipeline

### 2026-06-10 — Use Astro 5.9.0 (not 6.x) for the narrative site
- **Why:** `channel-profitability-analysis` runs Astro 5.9.0 + MDX + Cloudflare Pages successfully. Cloudflare adapter in static mode has a documented bug where it fails the build. Staying on 5.9.0 avoids the failure and gives a known-working template to clone from.
- **Scope:** `site/` directory, all Astro config and dependency decisions
- **Do not:** Upgrade to Astro 6.x without confirming the Cloudflare Pages static-mode adapter issue is resolved. Do not use the Cloudflare adapter at all — deploy as a static site.

### 2026-06-10 — Self-host fonts by copying woff2 files from the template, not @fontsource packages
- **Why:** The plan specified `@fontsource` packages, but the template already has exactly the right woff2 files (Playfair Display + Source Sans 3, latin + latin-ext, variable-weight) in `public/fonts/` with matching `@font-face` declarations in `src/styles/fonts.css`. Copying the files is one step vs. adding npm packages that themselves download the same woff2 bytes. The font loading approach (preload hints + CSS `@font-face`) is already working in the template.
- **Scope:** `site/public/fonts/`, `site/src/styles/fonts.css`
- **Do not:** Use Google Fonts CDN. Do not switch to @fontsource packages unless the template project switches first — keeping font loading strategy in sync across portfolio pieces reduces maintenance.

### 2026-06-10 — Scaffold `site/` from `channel-profitability-analysis`, not from scratch
- **Why:** That repo already has Astro 5.9.0 + MDX + selective D3 sub-modules + `@fontsource` self-hosted fonts + Cloudflare Pages config that works. Starting from scratch risks re-encountering solved problems (adapter static-mode bug, font CDN vs self-hosted, D3 tree-shaking).
- **Scope:** U1 scaffold task; sets all baseline dependency versions
- **Do not:** Pull from `create-astro` or any other template. Clone from `channel-profitability-analysis` directly.

---

## Data & Schema

[Decisions about data sources, schemas, transformations]

---

## Visualization

### 2026-06-10 — ERD uses three views with a toggle: Mermaid, D3 interactive, SVG download
- **Why:** User explicitly chose all three so visitors can pick the view that works for them — Mermaid for quick reading, D3 for interactive exploration, SVG for export/print. astro-mermaid (client-side) chosen over rehype-mermaid because rehype-mermaid requires Playwright/Chromium and has Windows rendering divergence.
- **Scope:** `site/src/components/ERD*` components, U3 implementation unit
- **Do not:** Use `dagre-d3` (abandoned, D3 v4, last release 2017) — use `@dagrejs/dagre` v3.0.0 + D3 v7 instead. Do not use `rehype-mermaid` (requires Playwright).

### 2026-06-10 — Call mermaid.render() directly in Astro scripts; do not rely on astro-mermaid integration scanning
- **Why:** `astro-mermaid` with `autoTheme: false` logs "No mermaid diagrams found on initial load" — it scans for `.mermaid` class elements but our component renders into a plain `<div>` via `mermaid.render()`. The integration does nothing useful for us. Direct API call is more explicit, more reliable, and doesn't depend on the integration's internal element-scanning behavior.
- **Scope:** `site/src/components/ERDMermaid.astro` and any future Mermaid components in `site/`
- **Do not:** Add class `mermaid` to elements expecting the integration to auto-render them. Call `mermaid.initialize()` and `mermaid.render()` explicitly instead.

### 2026-06-10 — Generate erd.svg by serializing the live D3 SVG in the browser, not by authoring it by hand
- **Why:** D3 + dagre produce exact node positions at runtime. Authoring SVG coordinates by hand would require re-running the dagre layout mentally — error-prone and fragile. The correct workflow: render the D3 view in the browser, run `new XMLSerializer().serializeToString(svgEl)` via `preview_eval`, clean the output (add background rect, remove Astro scoping attrs, add XML declaration), and commit.
- **Scope:** `site/public/downloads/erd.svg`; applies any time the ERD schema changes and erd.svg needs to be regenerated
- **Do not:** Edit erd.svg coordinates by hand. Always re-serialize from the live render.

---

## Deployment

### 2026-06-10 — Use Cloudflare REST API (not wrangler) to attach custom domains to Pages projects

- **Why:** wrangler v4 removed `wrangler pages domain add`. The Cloudflare REST API endpoint `POST /accounts/{id}/pages/projects/{name}/domains` works in all wrangler versions and is the current documented path. The API also returns `zone_tag` confirming auto-wiring when the domain's DNS zone is already on the same account.
- **Scope:** Any future `master.lailarallc.com` domain changes; applies to all portfolio pieces on Cloudflare Pages.
- **Do not:** Use `wrangler pages domain add` — it was removed in wrangler v4. Do not look for a wrangler flag replacement; the REST API is the canonical path.

---

## Output Formats

[Decisions about deliverable formats, structure, organization]

---

## Writing & Voice

[Voice, style, terminology decisions specific to this project]

---

## Reversed / Superseded

When a decision is overturned:
1. Strike through the original entry above (don't delete)
2. Add a new entry below with the replacement decision
3. Note the link in both directions

This preserves the history of why something is the way it is.
