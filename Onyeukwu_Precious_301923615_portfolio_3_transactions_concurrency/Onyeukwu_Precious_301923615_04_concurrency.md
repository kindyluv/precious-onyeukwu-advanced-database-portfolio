# Concurrency demonstration — two SQL sessions

Use two SQL terminals connected to the same test database. Both sessions start a transaction and update the SAME `wallets.id=501` row before deriving its available funds from `wallet_funding`. With overlapping transactions, at most one update can proceed without serializable contention; capture any contention, waiting, or SQLSTATE `40001` retry response.

Session A:
```sql
BEGIN;
UPDATE public.wallets SET date_modified=current_timestamp WHERE id=501;
SELECT SUM(CASE WHEN transaction_type='CREDIT' THEN amount ELSE -amount END) FROM public.wallet_funding WHERE wallet_fk=501;
-- Hold transaction open until Session B starts; COMMIT when ready.
COMMIT;
```

Session B: execute identical statements in a second connection while A is open. Record exactly what happens. **Do not assume a retry error must occur**: the database may wait, or observed results may differ by execution timing. Never call an external payment processor while the SQL transaction is open.

**Implementation limitation:** `wallets` has no materialized balance column. The demo proves SQL transaction semantics and snapshot/retry considerations, NOT a production-grade spending guard. A real service needs a transactionally enforced available-funds invariant, out-of-band processor reconciliation, and reliable idempotency. No new table is introduced due to the user's restriction.
