SELECT jsonb_build_object(
    'transactionReference', t.transaction_reference,
    'merchantReference', t.merchant_reference,
    'businessId', t.business_fk,
    'amount', t.amount,
    'feeAmount', t.fee_amount,
    'currency', c.code,
    'status', t.transaction_status,
    'sender', jsonb_build_object('name', s.name, 'phone', s.phone_number),
    'beneficiary', jsonb_build_object('accountName', b.account_name, 'bankCode', b.bank_code),
    'startedAt', t.started_at
) AS payout_document
FROM public.transactions t
LEFT JOIN public.currency c ON c.id=t.currency_fk
LEFT JOIN public.sender s ON s.id=t.sender_fk
LEFT JOIN public.beneficiary b ON b.id=t.beneficiary_fk
ORDER BY t.started_at DESC LIMIT 10;
