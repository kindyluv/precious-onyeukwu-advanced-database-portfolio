-- Only run on CONFIRMED definitive processor failure, once.
-- Unique funding_reference prevents replaying the same refund reference; a complete service must guard status transitions atomically.
BEGIN;
UPDATE public.transactions SET transaction_status='FAILED', status_reason='Confirmed processor failure', ended_at=current_timestamp
WHERE transaction_reference='TX-DEMO-1101' AND transaction_status='DEBITED';
-- STOP unless the UPDATE above changed exactly one row. SQL alone here does not make that check automatic.
INSERT INTO public.wallet_funding (id, amount, business_fk, currency_fk, date_created, funding_reference, transaction_type, wallet_fk, description)
VALUES (1103, 30300.00, 401, 101, current_timestamp, 'REFUND-TX-DEMO-1101', 'CREDIT', 501, 'Refund payout and fee on confirmed failure');
COMMIT;
SELECT wallet_fk, SUM(CASE WHEN transaction_type='CREDIT' THEN amount ELSE -amount END) AS derived_balance FROM public.wallet_funding WHERE wallet_fk=501 GROUP BY wallet_fk;
