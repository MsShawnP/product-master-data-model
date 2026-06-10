# Portfolio Project Brief: Product Master Data Model

**Created:** June 10, 2026
**Source:** `portfolio_priority_list_gtd.md` Next list
**Template:** `portfolio_brief_template.md`

**Status:** Brief stage
**Tier:** 1 (SSOT / data architecture)
**Priority:** Next #1 — lowest build cost of the five (the platform already IS the artifact), and it's the architectural companion the shipped Dimension & Weight Integrity piece keeps gesturing at.

### 1. The Pain

The buyer has product data in five places — ERP item master, 1WorldSync, the co-packer's spec sheets, retailer portals, Shopify — and no documented model of how a "product" actually relates to its GTINs, its case configurations, and the attribute set each retailer demands. Every new retailer onboarding re-derives this from scratch. Every new hire learns it by tribal knowledge. Nobody can answer "what is the canonical record for SKU X?" because there isn't one — there are five.

- **Who feels it:** COO and whoever owns item setup (often a single ops person). CEO feels it as launch delays.
- **When it becomes acute:** $15M–$25M, when retailer count crosses ~4 and the each/inner/case/pallet GTIN hierarchy stops being manageable in one spreadsheet.
- **How it compounds:** every new retailer adds an attribute schema; every new SKU multiplies across them. The shipped Dimension & Weight piece proved the cost of one field family diverging; this piece shows the structure that prevents all of them diverging.

#### The Status Quo

A "master" spreadsheet that is master of nothing, plus the ERP item list, plus whatever 1WorldSync currently says. Item setup forms get filled by copying from whichever source the person trusts that day.

### 2. Why This Piece

- **Builds on:** Cinderhaven Data Platform (the locked `dim_products` contract is the artifact), Dimension & Weight Integrity (proved the cost; this shows the cure's blueprint), Product Data Health Audit (found the defects; this is the schema that prevents them), Item Setup Form Pre-flight (consumes the retailer schemas this documents).
- **Proves what isn't yet demonstrated:** data *architecture* as a deliverable. Everything shipped so far diagnoses or quantifies; nothing yet shows "here is what a correctly modeled product master looks like." This is the closest piece to what an actual SSOT engagement would deliver.
- **Persona:** primary CEO/COO, but this is the first piece a client's *technical* counterpart (IT lead, fractional CTO, ERP admin) will evaluate seriously. It needs to survive that read.

### 3. The Portfolio Piece

**Working title:** *One Product, Five Definitions: The Data Model Your Product Master Should Have Had*

A reader walks one Cinderhaven SKU from brand → product → item (each) → inner → case → pallet, sees the GTIN assigned at each packaging level, then watches that hierarchy fan out into retailer-specific attribute requirements — and sees exactly which entities and relationships make this governable instead of chaotic.

#### Structure

- **Part 1 — The hook:** "Walmart, Costco, and UNFI are not asking you about the same product." One SKU, three retailer item-setup forms side by side, with the fields highlighted that map to *different levels* of the GTIN hierarchy. The reader realizes their flat spreadsheet cannot represent this.
- **Part 2 — The proof:** the documented model. Annotated ERD: `dim_products` and its satellites — packaging-level hierarchy (each/inner/case/pallet with per-level GTINs), physical attributes (owned per Dimension & Weight Integrity), regulatory attributes (allergens, nutritional, country of origin), retailer attribute mappings, and the syndication targets (GDSN/1WorldSync) as consumers, not sources. Each entity gets a "what breaks without it" callout.
- **Part 3 — The evidence:** the live contract. dbt docs site (lineage + column-level docs) published from the actual platform, Postgres DDL, dbt model contracts, the drift-guard script. The pitch: this isn't a whiteboard diagram — it runs.

#### The Margin Math

Reference, don't re-derive: PDHA established **$461K/yr** in chargeback cost from product-master defects at Cinderhaven's scale; Dimension & Weight established the per-field mechanics. This piece's claim: those costs are symptoms of a missing model, and the model costs a fraction of one year's leakage to establish. Add onboarding math: each retailer launch delayed by item-setup rejection ≈ 4–8 weeks of shelf revenue deferred (tie to Cost of Saying Yes cash-flow framing).

#### Before / After

- **Before:** five sources, zero canon; item setup is archaeology; every data question starts with "which system?"
- **After:** one documented model with named owners per attribute family; item setup forms are generated *from* the master; every downstream system is a subscriber.

#### Who Else Sees This?

- **Primary:** COO / ops lead.
- **Secondary:** IT lead / ERP admin / fractional CTO — the technical validator.
- **How it gets shared:** COO forwards the ERD page to IT with "is this what we should have?"

### 4. Technical Specification

- **Repo:** `product-master-data-model` — "The data model a specialty food product master should have — documented, contracted, and running on Postgres + dbt."

| Tool | Role |
|------|------|
| Postgres | The model itself (DDL, constraints) |
| dbt | Model contracts, tests, docs site (lineage) |
| Dagster | Asset graph showing consumers subscribing to the master |
| D3 or Mermaid | Interactive/annotated ERD for the narrative page |
| Quarto or Astro | The narrative walkthrough |

#### Deliverables

| Deliverable | Format | Purpose |
|------------|--------|---------|
| Narrative walkthrough | Web page (subdomain) | The buyer-facing story |
| Annotated ERD | Interactive D3/SVG | The screenshot piece |
| dbt docs site | Published static site | Technical proof it runs |
| DDL + contract files | Repo | Practitioner credibility |
| "What breaks without it" table | Section of walkthrough | Maps each entity to a shipped diagnostic piece |

#### Deployment

Cloudflare Pages, `master.lailarallc.com` (or `model.`). Found via portfolio /work page and cross-links from Dimension & Weight, PDHA, and Pre-flight.

#### Simulated Data Sources

None new — this documents the existing canonical platform. The narrative *names* the five real-world sources it replaces (NetSuite item master, 1WorldSync, co-packer specs, retailer portals, Shopify).

### 5. Skills Demonstrated

Dimensional modeling, GS1 packaging-hierarchy fluency, dbt contracts/tests/docs, data governance design, the ability to explain architecture to a non-technical operator.

### 6. Foot-in-the-Door Offering

- **Offering:** "Product Master Blueprint" — fixed-fee 2-week engagement.
- **Price range:** $12K–$20K.
- **Client gets:** documented current-state map (where product truth actually lives), target-state model adapted to their systems, attribute ownership matrix, migration sequence.
- **Client lift:** one 60-min kickoff + exports of item master, 1WorldSync extract, and two retailer setup forms. We do the rest.

#### The DIY Defense

The ERD looks copyable. What isn't: knowing that Costco's hierarchy treats the case as the saleable unit while Walmart's item setup keys on the each; that GDSN publication levels don't map 1:1 to internal packaging levels; that pallet-level GTINs (SSCC vs GTIN-14 with indicator digit) trip up every first-time modeler. The model encodes ten of these decisions invisibly.

### 7. Marketing / Distribution

- **Portfolio:** anchors a new "Architecture" grouping on /work alongside the Data Platform.
- **LinkedIn:** the side-by-side three-retailer-forms image. Hook: "These three forms are asking about three different products. They're all the same jar of marinara."
- **SEO:** "product master data model CPG," "GTIN hierarchy each inner case pallet," "PIM data model food brand."
- **Gating:** none. The model's value is the thinking; the moat is execution.

### 8. Competitor / Existing Content Scan

PIM vendors (Salsify, Syndigo) publish data-model content, but it's product marketing aimed at enterprise and assumes you buy their tool. GS1 publishes the standards but not an opinionated working model. **Gap:** an implementation-grade, vendor-neutral model sized for a $25M brand, with running code. **Angle:** "you don't need a PIM yet — you need a model."

### 9. Cinderhaven Integration

Pure documentation of the existing platform — zero new data. Must match `CINDERHAVEN_CANONICAL.md` exactly (50 SKUs, 5 lines, 6 retailers, 3 distributors + DTC). Reuses the locked `dim_products` contract verbatim. Hero SKU continuity: use CHP-0009 for the walkthrough.

### 10. Tactical Notes

- Verify GS1 indicator-digit and packaging-level terminology against gs1.org before publishing — this piece will be read by people who know.
- Don't let it become a dbt tutorial. The audience is the COO; the dbt docs are an appendix.
- Cross-link aggressively — this piece is the hub the diagnostics are spokes of.

#### The Credibility Marker

The Costco-vs-Walmart hierarchy divergence, and GTIN-14 indicator digits for case-level identification — the two things every generic data modeler gets wrong.

#### Data Paranoia / Security

Low — synthetic data, architecture content. Narrative note: the model is system-agnostic; an engagement adapts it to the client's ERP without exporting anything sensitive.

### 11. Open Questions

- [ ] Final title and subdomain
- [ ] ERD tooling: hand-built D3 vs Mermaid vs static SVG
- [ ] Whether to include a downloadable DDL "starter kit" (lead magnet) or keep DDL repo-only
- [ ] Where regulatory attributes (allergen/nutritional) sit — in scope or flagged as Recall Blast Radius territory

### 12. Build Estimate

- **Effort:** Small–Medium (1 build session for content + ERD; platform work already done)
- **Dependencies:** none — platform shipped
- **New skills:** none

#### Out of Scope

- No new dbt models or data generation
- No PIM tool comparison/selection content
- No lot/batch entities (that's Recall Blast Radius)


---
## Cross-brief notes

- **Canonical governance applies to all five.** Briefs 2 and 3 generate new data (genealogy, X12 corpus): new isolated seeds, registered in `CINDERHAVEN_CANONICAL.md`, drift-guard coverage, injected-error ledgers as validation ground truth. Briefs 1, 4, 5 generate none and must reconcile exactly.
- **Hero SKU continuity:** CHP-0009 is the worked example in briefs 1 and 4; candidate hero lot for brief 2.
- **Research tasks before any build:** FSMA 204 current enforcement dates + retailer mandates (brief 2); GS1 Sunrise 2027 current status (brief 4). Both verified at build time, not from memory.
- **Sequencing within the five:** 1 → 2 → 3 → 4 → 5 as listed. Brief 4 can float anywhere as filler. Brief 5 wants 2 and 3 done first or ships with two stubbed questions.
