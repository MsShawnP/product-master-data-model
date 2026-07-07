-- =============================================================================
-- dim_products_extended.sql
-- Entity: Product (anchor)
-- What breaks without this entity: Every downstream consumer — pricing,
-- distribution, retailer setup, chargebacks — loses its source of truth.
-- Without a governed product master, item setup is re-derived from tribal
-- knowledge at every new retailer launch.
--
-- This file documents the existing Cinderhaven dim_products contract
-- (columns present today) plus the packaging hierarchy columns that are
-- currently NULL or absent. Columns marked -- MISSING are either NULL in
-- the live data for CHP-0009 or do not exist at all in the current model.
-- The satellite tables (dim_packaging_levels, dim_gtin_assignments,
-- dim_retailer_attributes) capture what this flat model cannot.
--
-- Do not modify: this contract is locked and reused verbatim from the
-- Cinderhaven Data Platform. The satellite tables extend it; they do not
-- replace it.
-- =============================================================================

CREATE TABLE dim_products (
  -- Core identity
  sku                    TEXT         NOT NULL PRIMARY KEY,
  product_name           TEXT         NOT NULL,
  product_line           TEXT         NOT NULL
                           CHECK (product_line IN (
                             'Artisan Sauces',
                             'Pantry Staples',
                             'Specialty Condiments',
                             'Dried Goods',
                             'Snack Bites'
                           )),
  subcategory            TEXT,
  brand_owner            TEXT,
  country_of_origin      TEXT,
  last_updated           TIMESTAMPTZ,

  -- Barcodes (case level)
  -- CHP-0009: gtin14='10614140000904', upc='614140000907'
  -- Note: these are case-level identifiers only. Per-packaging-level GTINs
  -- (each, inner, pallet/SSCC) live in dim_gtin_assignments.
  gtin14                 TEXT,        -- GTIN-14, 14 digits including indicator digit
  upc                    TEXT,        -- UPC-A (GTIN-12) or EAN-13

  -- Case pack configuration
  case_pack_qty          INTEGER,     -- Units per case. CHP-0009: 24

  -- Physical dimensions — case level
  -- CHP-0009: all four below are NULL in the live platform.
  -- These are the gaps this model documents.
  unit_weight_lbs        NUMERIC(8,4),
  case_weight_lbs        NUMERIC(8,4), -- MISSING: NULL for CHP-0009
  case_length_in         NUMERIC(8,4), -- MISSING: NULL for CHP-0009
  case_width_in          NUMERIC(8,4), -- MISSING: NULL for CHP-0009
  case_height_in         NUMERIC(8,4), -- MISSING: NULL for CHP-0009

  -- Pricing
  msrp                   NUMERIC(10,2),
  cogs_per_unit          NUMERIC(10,4) NOT NULL,
  landed_cost_per_unit   NUMERIC(10,4),
  wholesale_price        NUMERIC(10,4) NOT NULL,
  margin_per_unit        NUMERIC(10,2) NOT NULL,   -- GENERATED in dbt
  margin_pct             NUMERIC(6,4)  NOT NULL,   -- GENERATED in dbt
  dtc_margin_per_unit    NUMERIC(10,2),
  dtc_margin_pct         NUMERIC(6,4),

  -- Retailer-specific wholesale pricing
  wholesale_walmart      NUMERIC(10,4),
  wholesale_costco       NUMERIC(10,4),
  wholesale_whole_foods  NUMERIC(10,4),
  wholesale_sprouts      NUMERIC(10,4),
  wholesale_regional     NUMERIC(10,4),
  wholesale_unfi         NUMERIC(10,4),
  wholesale_kehe         NUMERIC(10,4),
  wholesale_dtc          NUMERIC(10,4),

  -- Trade spend by channel (as decimal, e.g. 0.15 = 15%)
  trade_spend_pct_walmart     NUMERIC(6,4),
  trade_spend_pct_costco      NUMERIC(6,4),
  trade_spend_pct_whole_foods NUMERIC(6,4),
  trade_spend_pct_sprouts     NUMERIC(6,4),
  trade_spend_pct_regional    NUMERIC(6,4),
  trade_spend_pct_unfi        NUMERIC(6,4),
  trade_spend_pct_kehe        NUMERIC(6,4),
  trade_spend_pct_dtc         NUMERIC(6,4),

  -- Distribution breadth (derived, maintained by dbt)
  retailer_count         INTEGER      NOT NULL DEFAULT 0,
  distributor_count      INTEGER      NOT NULL DEFAULT 0,
  authorized_store_count INTEGER      NOT NULL DEFAULT 0
);

-- =============================================================================
-- What is NOT in this table (by design):
--
-- MISSING: Inner pack quantity and GTIN   → see dim_packaging_levels
-- MISSING: Each-level GTIN (GTIN-12/13)  → see dim_gtin_assignments
-- MISSING: Pallet SSCC                   → see dim_gtin_assignments
-- MISSING: Per-retailer attribute sets   → see dim_retailer_attributes
--   (e.g. Walmart item setup fields, Costco warehouse fields, UNFI EDI fields)
--
-- CHP-0009 today:
--   sku             = 'CHP-0009'
--   product_name    = 'Calabrian Chili Marinara'
--   gtin14          = '10614140000904'
--   upc             = '614140000907'
--   case_pack_qty   = 24
--   msrp            = 12.50
--   case_weight_lbs = NULL   ← the problem this model solves
--   case_length_in  = NULL   ←
--   case_width_in   = NULL   ←
--   case_height_in  = NULL   ←
-- =============================================================================
