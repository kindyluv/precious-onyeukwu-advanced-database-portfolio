# Portfolio 3 — Transactions and Concurrency

## Tests
1. Run `03_rollback_demo.sql` and confirm no movement remains.
2. Review `01_debit_demo.sql`; check funds and run it ONCE only under manual supervision.
3. For confirmed processor failure, run `02_refund_demo.sql` only once, after verifying that the state update matched one row.
4. Use two sessions following `04_concurrency.md`; capture observed locks/conflicts and any SQLSTATE 40001.

The `wallet_funding.funding_reference` unique constraint helps prevent exact duplicate entries. It does **not** by itself protect all idempotent workflow transitions. Unknown processor results must stay pending, not automatically refunded.
