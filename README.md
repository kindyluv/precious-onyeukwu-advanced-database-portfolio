# MIT 8103 — Advanced Database Systems Portfolio

**Selected case study:** Merchant-funded B2C cross-processor payout platform (simulated). **Primary database:** CockroachDB. **Assessment:** 5 practical portfolios + 2–3-page LMS summary. **Deadline:** 14 November 2026.

## Business model (do not confuse with customer onboarding)

Merchants are onboarded and maintain distinct wallets for each currency. Merchants submit payout instructions carrying the sender and beneficiary details required for that particular payout; **beneficiaries/consumers do not register or have platform wallets**. For each request, the system calculates fees, debits the appropriate merchant currency wallet for **principal + fee**, and dispatches the payout to a selected processor **after the database commit**. On a confirmed terminal processor failure, it refunds the entire debit exactly once. Unknown/time-out results remain pending for reconciliation.

## Repository reading / execution order

1. `portfolio-1-database-design/erd-original.mmd` — baseline ERD; `erd-corrected.mmd` — revised payout model; `01_schema.sql` then `02_seed.sql` — run only in disposable CockroachDB; `03_design-and-normalisation.md` — design rationale.
2. `portfolio-2-query-optimisation/` — reporting SQL, indexing, genuine EXPLAIN ANALYZE and before/after observations.
3. `portfolio-3-transactions-concurrency/` — atomic debit, full refund, rollback and concurrency, plus limitations of demonstration scripts.
4. `portfolio-4-nosql/` — MongoDB payout event document (separate model, not ledger authority).
5. `portfolio-5-distributed-cloud/` — CockroachDB topology, replication, consistency and actual deployment evidence.
6. `evidence/` — real redacted output, screenshots and observations, grouped by portfolio.
7. `docs/PROCESS-FLOW.md` — correct payout sequence; `docs/git-push-plan.md` — dated staged push schedule; `docs/drafts/` — report templates requiring your genuine results and reflection.

## Important integrity/safety notes

The scripts are educational examples, not a verified production payment engine. The transaction demo uses fixed test values and requires the caller to stop/rollback when a guarded update affects zero rows. CockroachDB retry errors require retrying the full transaction. Do not execute external payout integrations with live money. Only use synthetic sender/beneficiary data; never commit credentials or real PII. Obtain real query outputs, evidence and your own technical reflection before presenting this as completed work.

