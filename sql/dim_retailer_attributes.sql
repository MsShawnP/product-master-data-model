-- =============================================================================
-- dim_retailer_attributes.sql
-- Entity: Retailer Attribute
-- What breaks without this entity: Every retailer launch requires manually
-- translating the product master into a retailer-specific spreadsheet or portal
-- upload. With no governed attribute map, the same field appears under five
-- different names across five portals, and the wrong packaging level gets keyed
-- in on the wrong form. Chargebacks follow.
--
-- This table is a key-value store by design. Retailers add and deprecate fields
-- faster than a column-based schema can absorb. The attribute_key is the
-- retailer's own field name (e.g. 'walmart_item_setup_gtin', 'costco_vendor_nbr').
-- =============================================================================

CREATE TABLE dim_retailer_attributes (
  sku               TEXT         NOT NULL
                      REFERENCES dim_products (sku),
  retailer          TEXT         NOT NULL
                      CHECK (retailer IN (
                        'Walmart',
                        'Costco',
                        'Whole Foods',
                        'Sprouts',
                        'Kroger',
                        'Regional Group',  -- Represents regional grocery chains
                        'UNFI',
                        'KeHE',
                        'DTC'
                      )),
  attribute_key     TEXT         NOT NULL,   -- The retailer's field name
  attribute_value   TEXT,                    -- The value for this SKU

  -- Which entity in this model is the source of truth for this attribute.
  -- e.g. 'dim_products', 'dim_packaging_levels', 'dim_gtin_assignments'
  attribute_source  TEXT         NOT NULL,

  -- When this attribute was last verified against the retailer's portal
  last_synced       TIMESTAMPTZ,

  PRIMARY KEY (sku, retailer, attribute_key)
);

-- =============================================================================
-- Sample attribute rows for CHP-0009 across three retailers:
--
-- Walmart keys item setup on the EACH (consumer unit GTIN-12):
--
--   (CHP-0009, Walmart, walmart_gtin,            '0074000090',     dim_gtin_assignments, ...)
--   (CHP-0009, Walmart, walmart_unit_of_measure,  'EA',            dim_packaging_levels, ...)
--   (CHP-0009, Walmart, walmart_unit_msrp,        '12.50',         dim_products,         ...)
--   (CHP-0009, Walmart, walmart_unit_weight_lbs,  '1.25',          dim_packaging_levels, ...)
--   (CHP-0009, Walmart, walmart_unit_length_in,   NULL,  -- MISSING dim_packaging_levels, ...)
--   (CHP-0009, Walmart, walmart_unit_width_in,    NULL,  -- MISSING dim_packaging_levels, ...)
--   (CHP-0009, Walmart, walmart_unit_height_in,   NULL,  -- MISSING dim_packaging_levels, ...)
--
-- Costco's selling unit is the bulk case (GTIN-14 as consumer unit):
--
--   (CHP-0009, Costco, costco_gtin,               '00850074000090', dim_gtin_assignments, ...)
--   (CHP-0009, Costco, costco_case_pack,           '24',            dim_packaging_levels, ...)
--   (CHP-0009, Costco, costco_case_weight_lbs,     NULL,  -- MISSING dim_packaging_levels, ...)
--   (CHP-0009, Costco, costco_case_cube_in3,       NULL,  -- MISSING dim_packaging_levels, ...)
--   (CHP-0009, Costco, costco_warehouse_price,     NULL,            dim_products,         ...)
--
-- UNFI requires the case hierarchy for EDI 832 item setup:
--
--   (CHP-0009, UNFI, unfi_case_gtin,              '00850074000090', dim_gtin_assignments, ...)
--   (CHP-0009, UNFI, unfi_case_pack_qty,           '24',            dim_packaging_levels, ...)
--   (CHP-0009, UNFI, unfi_shipped_weight_lbs,      NULL,  -- MISSING dim_packaging_levels, ...)
--   (CHP-0009, UNFI, unfi_shipped_length_in,       NULL,  -- MISSING dim_packaging_levels, ...)
--   (CHP-0009, UNFI, unfi_fob_price,               NULL,            dim_products,         ...)
--
-- Every NULL above is traceable to the same root cause:
-- case_weight_lbs and case dimensions are NULL in dim_products for CHP-0009.
-- dim_packaging_levels is where those values belong, once they are captured.
-- =============================================================================
