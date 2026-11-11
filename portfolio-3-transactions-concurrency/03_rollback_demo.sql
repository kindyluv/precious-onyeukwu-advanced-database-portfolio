BEGIN;
UPDATE public.wallets SET date_modified=current_timestamp WHERE id=501;
INSERT INTO public.wallet_funding (id, amount, business_fk, currency_fk, date_created, funding_reference, transaction_type, wallet_fk)
VALUES (1199, 20.00, 401, 101, current_timestamp, 'ROLLBACK-DEMO', 'DEBIT', 501);
ROLLBACK;
SELECT COUNT(*) AS should_be_zero FROM public.wallet_funding WHERE funding_reference='ROLLBACK-DEMO';
