-- DEMONSTRATION ONLY; do not run twice unchanged. Uses existing wallets, wallet_funding, transactions.
-- Compute balance first; only proceed if available >= 30,300 (amount 30,000 + fee 300).
SELECT COALESCE(SUM(CASE WHEN transaction_type='CREDIT' THEN amount ELSE -amount END),0) AS balance_before FROM public.wallet_funding WHERE wallet_fk=501;
-- The application must retry on SQLSTATE 40001 and MUST ensure idempotency before entering this transaction.
BEGIN;
-- Write intent on shared wallet row to induce a serializable write conflict between concurrent spenders.
UPDATE public.wallets SET date_modified=current_timestamp WHERE id=501 AND is_active=true;
-- The CHECK below is a query result for review, NOT a SQL conditional guard: scripts must not treat it as sufficient-funds enforcement.
SELECT COALESCE(SUM(CASE WHEN transaction_type='CREDIT' THEN amount ELSE -amount END),0) AS balance_inside_txn FROM public.wallet_funding WHERE wallet_fk=501;
-- Only execute the following two INSERTs if the application / supervising transaction logic confirms funds and wallet ownership.
INSERT INTO public.transactions (id, amount, business_fk, currency_fk, started_at, transaction_reference, merchant_reference, transaction_status, transaction_type, fee_amount, wallet_reference, sender_fk, beneficiary_fk, country_fk)
VALUES (1101, 30000.00, 401, 101, current_timestamp, 'TX-DEMO-1101', 'MERCH-DEMO-1101', 'DEBITED', 'PAYOUT', 300.00, 'WAL-NGN-501', 701, 801, 201);
INSERT INTO public.wallet_funding (id, amount, business_fk, currency_fk, date_created, funding_reference, transaction_type, wallet_fk, description)
VALUES (1102, 30300.00, 401, 101, current_timestamp, 'PAYOUT-DEBIT-TX-DEMO-1101', 'DEBIT', 501, 'Payout plus fee debit for TX-DEMO-1101');
COMMIT;
SELECT * FROM public.transactions WHERE transaction_reference='TX-DEMO-1101';
