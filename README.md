# product-master-data-model

**Live:** https://master.lailarallc.com

The data model a specialty food product master should have — documented, contracted, and running on Postgres + dbt.

## Cinderhaven context

Built on the Cinderhaven synthetic dataset — a ~$25M specialty food brand,
50 SKUs across 5 product lines and 6 contracted retailers. Data is synthetic;
methodology and deliverables are real.

## What it does

Walks one SKU from brand → product → each → inner → case → pallet, assigns GTINs at each packaging level, and fans that hierarchy out into the attribute sets each retailer requires. Shows exactly which entities and relationships make this governable instead of chaotic.

## Stack

- Postgres — DDL, constraints, the model itself
- dbt — model contracts, schema tests, published docs site
- Astro — narrative web page
- D3 / Mermaid — annotated ERD
- Cloudflare Pages (Wrangler) — deployment

## Data contract

**Canonical baseline:** 50 SKUs · 5 product lines (AS·PS·SC·DG·SB) · 6 retailers
(Walmart·Costco·Whole Foods·Sprouts·Kroger·Regional Group) · 10 channels
(6 retail + UNFI·KeHE·DPI + DTC)

Reuses the locked `dim_products` contract from the Cinderhaven Data Platform verbatim. Hero SKU: CHP-0009.

## Run

```
git clone https://github.com/MsShawnP/product-master-data-model.git
cd product-master-data-model/site
npm install
npm run dev        # narrative site at localhost:4321
npm run build      # production build to dist/
```

The Postgres DDL lives in `sql/` — four dimension tables (products extended, packaging levels, GTIN assignments, retailer attributes). Apply with `psql -f sql/<file>.sql` against the Cinderhaven Data Platform database. dbt model contracts and schema tests are deferred until that platform's Postgres instance is available.

---

Built by [Lailara LLC](https://lailarallc.com) — data hygiene and analytics
consulting for specialty food brands scaling into national retail.
