# product-master-data-model

The data model a specialty food product master should have — documented, contracted, and running on Postgres + dbt.

**Live:** https://master.lailarallc.com

## What it does

Walks one SKU from brand → product → each → inner → case → pallet, assigns GTINs at each packaging level, and fans that hierarchy out into the attribute sets each retailer requires. Shows exactly which entities and relationships make this governable instead of chaotic.

## Stack

- Postgres — DDL, constraints, the model itself
- dbt — model contracts, schema tests, published docs site
- Astro — narrative web page
- D3 / Mermaid — annotated ERD
- Dagster — asset graph showing downstream consumers
- Cloudflare Pages — deployment

## How to run

_Setup instructions coming once stack is finalized._

## Part of Cinderhaven

Uses the locked `dim_products` contract from the Cinderhaven Data Platform. Hero SKU: CHP-0009. Canonical figures: 50 SKUs, 5 lines, 6 retailers, 3 distributors + DTC.

---

Built by [Lailara LLC](https://lailarallc.com) — data hygiene and analytics consulting for specialty food brands scaling into national retail.
