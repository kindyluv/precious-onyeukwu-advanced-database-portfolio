SHOW TABLES;
SHOW CREATE TABLE public.transactions;
SHOW CREATE TABLE public.wallet_funding;
SELECT b.id, b.name, w.wallet_reference, c.code AS currency_code
FROM public.business b JOIN public.wallets w ON w.business_fk = b.id JOIN public.currency c ON c.id = w.currency_fk ORDER BY b.id, c.code;
SELECT wallet_fk, SUM(CASE WHEN transaction_type='CREDIT' THEN amount ELSE -amount END) AS derived_balance FROM public.wallet_funding GROUP BY wallet_fk;

SELECT count(*) AS actual_foreign_keys FROM information_schema.table_constraints WHERE table_schema = 'public' AND constraint_type = 'FOREIGN KEY';
