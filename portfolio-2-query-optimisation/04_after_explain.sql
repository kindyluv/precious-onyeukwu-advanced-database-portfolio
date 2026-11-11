-- Run AFTER 03_optimise_indexes.sql.
EXPLAIN ANALYZE SELECT id, transaction_reference, amount, transaction_status, started_at
FROM public.transactions WHERE business_fk=401 AND transaction_type='PAYOUT' ORDER BY started_at DESC LIMIT 50;
EXPLAIN ANALYZE SELECT * FROM public.wallet_funding WHERE wallet_fk=501 ORDER BY date_created DESC LIMIT 50;
