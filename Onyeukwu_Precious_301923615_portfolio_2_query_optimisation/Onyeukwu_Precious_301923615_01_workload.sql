-- Query A: merchant payout history.
SELECT id, transaction_reference, merchant_reference, amount, fee_amount, transaction_status, started_at
FROM public.transactions WHERE business_fk = 401 AND transaction_type = 'PAYOUT'
ORDER BY started_at DESC LIMIT 50;

-- Query B: status totals by currency
SELECT c.code, t.transaction_status, COUNT(*) AS transaction_count,
       SUM(COALESCE(t.amount,0)) AS total_amount
FROM public.transactions t JOIN public.currency c ON c.id=t.currency_fk
GROUP BY c.code, t.transaction_status ORDER BY c.code, t.transaction_status;

-- Query C: net wallet funding movement by currency
SELECT w.wallet_reference, c.code,
       SUM(CASE WHEN f.transaction_type = 'CREDIT' THEN f.amount ELSE -f.amount END) AS derived_balance
FROM public.wallet_funding f JOIN public.wallets w ON w.id=f.wallet_fk
JOIN public.currency c ON c.id=w.currency_fk
WHERE w.business_fk=401 GROUP BY w.wallet_reference,c.code;
