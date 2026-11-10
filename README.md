# MIT 8103 — Merchant-Funded B2C Payout Platform

## Payout workflow
Merchants own wallets differentiated by currency. Merchants submit payouts with sender and beneficiary details; the platform computes fees, debits the corresponding merchant wallet, selects a processor, and dispatches after the database commit. A confirmed processor failure causes a full amount-plus-fee reversal. See `docs/PAYOUT_FLOW.md` for architectural compromises imposed by this schema.

## Portfolio map
| Portfolio | Contents | Evidence to capture |
|---|---|---|
| 1 Design | source-converted DDL, ERD, seeds, key review | SHOW TABLES, constraints, render |
| 2 Optimisation | operational queries, baseline plans, candidate indexes, post-index plans | EXPLAIN ANALYZE comparisons |
| 3 Transactions | debit/refund/rollback demos, concurrency sessions | commits, rollbacks, observed contention |
| 4 NoSQL/advanced model | document-shaped JSON projection of existing rows | executed query output, document-model evaluation |
| 5 Distributed/cloud | CockroachDB ranges, cluster setup, consistency | real node/range/replica evidence |

## Run order
Follow `docs/README_SQL_RUN_ORDER.md`. Each portfolio directory has its own README. All SQL must run against a disposable test database containing synthetic data; the source has credential and identity fields.

## Important limitations
- Fields named `_fk` are not all declared database foreign keys; the ERD does not pretend otherwise.
- `wallets` has no current-balance column. The demo uses a net `wallet_funding` movement sum, which **is not a full financial ledger**.
- There is no durable outbox or processor-attempt table; external processor retries and uncertainty are documented rather than invented.
- The P3 debit/refund SQL requires manual checks; it is **not** a safe production payment engine.
- P4 demonstrates a JSON document representation within CockroachDB without a separate NoSQL deployment.

## References
- University MIT 8103 assessment requirements (provided)
- https://www.cockroachlabs.com/docs/stable/create-table
- https://www.cockroachlabs.com/docs/stable/explain-analyze
- https://www.cockroachlabs.com/docs/stable/transactions
- https://www.cockroachlabs.com/docs/stable/show-ranges

## AI-use notice
 Mermaid ERD, documentation and test scaffolding were assisted by ChatGPT.
