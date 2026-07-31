# Product Master Data Model — The Data Model a Specialty Food Product Master Should Have

**Live:** https://master.lailarallc.com

Documented, contracted, and running on Postgres + dbt: the entity model that keeps a growing brand's product data governable instead of chaotic.

## What it does

Walks one SKU from brand → product → each → inner → case → pallet, assigns GTINs at each packaging level, and fans that hierarchy out into the attribute sets each retailer requires. Shows exactly which entities and relationships make this governable instead of chaotic.

Deliverables:

- **Narrative site** (Astro) with an annotated, interactive ERD (D3 / Mermaid) — the argument for the model, readable by a non-engineer
- **Postgres DDL** in `sql/` — four dimension tables: products extended, packaging levels, GTIN assignments, retailer attributes
- **dbt model contracts and schema tests** — deferred until the Cinderhaven Data Platform Postgres instance is available

## Why it matters

Most product-data pain — chargebacks, item-setup rejections, syndication errors, freight disputes — traces back to a product master that was never modeled, just accumulated in spreadsheets. When packaging levels, GTINs, and retailer-specific attributes have explicit entities, keys, and constraints, every downstream form and feed becomes a query instead of a re-keying exercise. This repo is the reference for what that structure looks like for a specialty food brand.

## Cinderhaven context

Built on the Cinderhaven synthetic dataset — a specialty food brand doing $33.4M TTM revenue (retail scan, through 2025-12-27), 50 SKUs across 5 product lines and 6 contracted retailers. Data is synthetic; methodology and deliverables are real.

## Data contract

**Canonical baseline:** 50 SKUs · 5 product lines (AS·PS·SC·DG·SB) · 6 retailers (Walmart·Costco·Whole Foods·Sprouts·Kroger·Regional Group) · 10 channels (6 retail + UNFI·KeHE·DPI + DTC)

Reuses the locked `dim_products` contract from the Cinderhaven Data Platform verbatim. Hero SKU: CHP-0009.

**Known model gaps:** the locked `dim_products` contract carries no `wholesale_kroger` / `trade_spend_pct_kroger` columns — Kroger trade terms are proxied from Regional Group downstream (e.g. the PDHA P&L) — and `dim_retailer_attributes` does not enumerate DPI. Both are flagged for a platform schema decision; this repo documents the contract as locked rather than extending it.

## Quick start

```
git clone https://github.com/MsShawnP/product-master-data-model.git
cd product-master-data-model/site
npm install
npm run dev        # narrative site at localhost:4321
npm run build      # production build to dist/
```

The Postgres DDL lives in `sql/`. Apply with `psql -f sql/<file>.sql` against the Cinderhaven Data Platform database.

## Tech stack

- **Postgres** — DDL, constraints, the model itself
- **dbt** — model contracts, schema tests, published docs site
- **Astro** — narrative web page
- **D3 / Mermaid** — annotated ERD
- **Cloudflare Pages (Wrangler)** — deployment (`npm run deploy` from `site/`)

## Project structure

```
site/     Astro narrative site with interactive ERD
sql/      dim_products_extended, dim_packaging_levels,
          dim_gtin_assignments, dim_retailer_attributes
docs/     supporting documentation
tests/    test suite
```

## License

MIT

---

Built by [Lailara LLC](https://lailarallc.com) — data hygiene and analytics consulting for specialty food brands scaling into national retail.
