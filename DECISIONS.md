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
