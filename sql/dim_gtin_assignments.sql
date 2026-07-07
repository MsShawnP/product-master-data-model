-- =============================================================================
-- dim_gtin_assignments.sql
-- Entity: GTIN Assignment
-- What breaks without this entity: Each retailer independently re-derives which
-- GTIN to put on their item setup form. Walmart takes the UPC. Costco takes the
-- case GTIN-14. UNFI's EDI 832 takes the case GTIN-14. When those values live
-- in a spreadsheet with no level annotation, the wrong GTIN ends up on the wrong
-- form — and the item setup is rejected.
--
-- GS1 indicator digits: digits 1–8 in a GTIN-14 carry NO standardized meaning.
-- GS1 has not assigned semantic definitions to indicator values. The digit is
-- brand-assigned. Do not present a mapping (1=each, 2=case) as a GS1 standard.
-- =============================================================================

CREATE TABLE dim_gtin_assignments (
  sku                TEXT         NOT NULL
                       REFERENCES dim_products (sku),
  packaging_level    TEXT         NOT NULL,
                       -- FK to dim_packaging_levels (sku, packaging_level) is a
                       -- composite reference — added via ALTER TABLE below.
  gtin               TEXT         NOT NULL,
  gtin_type          TEXT         NOT NULL
                       CHECK (gtin_type IN ('GTIN-12', 'GTIN-13', 'GTIN-14', 'SSCC')),

  -- indicator_digit: the leading digit of a GTIN-14 (positions 1 of 14).
  -- Valid for gtin_type = 'GTIN-14' only; NULL for all other types.
  -- Range 1–8 per GS1 spec; 0 is used when a GTIN-12/13 is zero-padded to 14 digits.
  -- IMPORTANT: GS1 indicator digits 1–8 carry no standardized meaning;
  -- the value is brand-assigned. See GS1 General Specifications §2.1.14.
  indicator_digit    INTEGER       CHECK (indicator_digit BETWEEN 0 AND 8),

  -- is_trade_item: TRUE if this GTIN identifies an orderable trade unit.
  -- Pallet SSCCs are logistics identifiers, not trade item GTINs.
  is_trade_item      BOOLEAN       NOT NULL DEFAULT TRUE,

  PRIMARY KEY (sku, packaging_level)
);

-- Composite FK constraint (Postgres requires this syntax for composite references):
ALTER TABLE dim_gtin_assignments
  ADD CONSTRAINT fk_gtin_packaging
  FOREIGN KEY (sku, packaging_level)
  REFERENCES dim_packaging_levels (sku, packaging_level);

-- Expected rows for CHP-0009:
--
-- sku      | packaging_level | gtin             | gtin_type | indicator_digit | is_trade_item
-- CHP-0009 | each            | 614140000907     | GTIN-12   | NULL            | TRUE
-- CHP-0009 | case            | 10614140000904   | GTIN-14   | 1               | TRUE
-- CHP-0009 | pallet          | [SSCC value]     | SSCC      | NULL            | FALSE
--
-- No row for 'inner' — Cinderhaven does not assign a GTIN to the inner pack
-- for CHP-0009. That is a gap in the current product data, not a GS1 rule.
--
-- The indicator digit '1' in '10614140000904' is brand-assigned. The remaining
-- digits embed the GTIN-12's company prefix and item reference (061414000090,
-- zero-padded) with a recomputed mod-10 check digit. GS1 assigns no semantic
-- meaning to the indicator value.
