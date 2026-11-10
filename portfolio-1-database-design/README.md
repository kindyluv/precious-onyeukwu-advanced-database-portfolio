# Portfolio 1 — Database Design and Modelling (7 marks)

## Execute
1. Run `01_schema_cockroachdb.sql` in a blank assessment database.
2. Run `03_seed.sql` for fictional reference records.
3. Run `04_verification.sql` and capture outputs.
4. Run `05_orphan_precheck.sql` when migrating existing data.
5. Render `erd.mmd` in Mermaid.
6. Review `relationship_review.md`.

## Normalisation discussion
Primary keys identify rows. The major tables separate merchant configuration (`business`, `business_profile`), static data (`currency`, `country`, `banks`), operational requests (`transactions`, `sender`, `beneficiary`), and routing/fee setup. `transactions` stores operational snapshots such as processor codes and settlement fields; that is deliberate denormalization for historical reporting.

## Evidence
Constraint test failure and three real query results are saved to `../evidence/portfolio-1/` based on `SHOW TABLES` output.
