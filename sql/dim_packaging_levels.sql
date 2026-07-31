-- =============================================================================
-- dim_packaging_levels.sql
-- Entity: Packaging Level
-- What breaks without this entity: Item setup forms are filled by archaeology.
-- Walmart needs the each's weight. UNFI needs the case's shipped weight. Costco
-- needs the case cube. Without a governed packaging hierarchy, every retailer
-- launch starts from scratch — or from whatever the co-packer's spec sheet says,
-- which may not match what shipped.
--
-- CHP-0009 currently: case_weight_lbs = NULL in dim_products. This table is
-- where that value belongs — at the level that owns it.
-- =============================================================================

CREATE TABLE dim_packaging_levels (
  sku                TEXT         NOT NULL
                       REFERENCES dim_products (sku),
  packaging_level    TEXT         NOT NULL
                       CHECK (packaging_level IN ('each', 'inner', 'case', 'pallet')),

  -- Hierarchy position
  -- quantity_per_level: how many of the next-lower level fit in this one.
  -- For 'each': quantity_per_level = 1 (base unit).
  -- For 'inner': quantity_per_level = units per inner pack (e.g. 6).
  -- For 'case': quantity_per_level = inners per case, or units per case if no inner.
  -- For 'pallet': quantity_per_level = cases per pallet layer × layers.
  quantity_per_level INTEGER      NOT NULL CHECK (quantity_per_level > 0),

  -- Physical attributes at this packaging level
  -- All nullable — not every brand tracks dimensions at every level.
  -- Pallet dimensions are typically carrier-defined, not brand-defined.
  level_weight_lbs   NUMERIC(8,4),
  level_length_in    NUMERIC(8,4),
  level_width_in     NUMERIC(8,4),
  level_height_in    NUMERIC(8,4),

  -- Calculated cube (length × width × height in cubic inches)
  -- Derived in application layer; included here for reference.
  level_cube_in3     NUMERIC(12,4)
                       GENERATED ALWAYS AS (level_length_in * level_width_in * level_height_in)
                       STORED,

  PRIMARY KEY (sku, packaging_level)
);

-- Expected rows for CHP-0009:
--
-- sku      | packaging_level | quantity_per_level | level_weight_lbs | ...
-- CHP-0009 | each            | 1                  | 1.25             | ...  (one 10oz jar)
-- CHP-0009 | inner           | 6                  | NULL             | ...  (6-pack tray)
-- CHP-0009 | case            | 4                  | NULL  ← gap      | ...  (4 six-pack inners = 24-unit master case)
-- CHP-0009 | pallet          | 48                 | NULL             | ...  (48 cases per pallet)
--
-- Note: inner pack is optional. If the brand ships each directly to case,
-- insert a row with quantity_per_level = case_pack_qty and mark it 'case'.
-- Do not skip the 'inner' level row — insert it with NULL dimensions if the
-- level exists but dimensions are unknown.
