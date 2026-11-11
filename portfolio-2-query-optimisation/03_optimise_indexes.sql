CREATE INDEX IF NOT EXISTS idx_portfolio_transactions_merchant_type_date ON public.transactions (business_fk, transaction_type, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_portfolio_funding_wallet_date ON public.wallet_funding (wallet_fk, date_created DESC);
