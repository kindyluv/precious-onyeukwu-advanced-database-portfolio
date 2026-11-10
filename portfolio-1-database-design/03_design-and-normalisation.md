# Design and normalisation (Portfolio 1)

## Source ERD mapping
Keep: `BUSINESS`, `BUSINESS_PROFILE`, `WHITELISTED_IP_ADDRESS`, `WALLET`, `WALLET_FUNDING`, `TRANSACTION_RECORD`, `SENDER`, `BENEFICIARY`, `CURRENCY`, `COUNTRY`, `TRANSFER_PROCESSOR`, `CUSTOM_TRANSFER_PROCESSOR`, `ROUTING_RULE`, `RISK_ROUTER`, `BLOCKED_ACCOUNT`, `BUSINESS_BLACKLIST`, `BANK`, `FEE_CONFIG`, `CUSTOM_FEE_CONFIG`, `AUDIT_LOG`; optional voucher depending on actual product requirements. Original ERD preserved as `erd-original.mmd`.

Refinements: rename `TRANSACTION_RECORD` to `PAYOUT`; consolidate `SENDER` and `BENEFICIARY` into a single 1:1 payout snapshot (`PAYOUT_PARTIES`) because names and bank details are provided by the merchant on each request, not maintained as customers. Keep only masked/tokenised sensitive account references in demonstrations. No platform `CUSTOMER` or end-user wallet.

Additional tables: `PAYOUT_STATUS_HISTORY`, `PROCESSOR_ATTEMPT`, `PROCESSOR_WEBHOOK`, `OUTBOX_EVENT`, `LEDGER_ACCOUNT`, `LEDGER_JOURNAL`, `LEDGER_ENTRY`.

## Functional dependencies and constraints
- Business → many wallets; `(business_id, currency_id)` identifies a wallet; wallets are not shared across businesses.
- `(business_id, merchant_reference)` and `(business_id, request_key)` uniquely identify a payout; a retry with same key but different request hash must be rejected by the service.
- `wallet_id` + `business_id` + `currency_id` composite FK prevents spending another merchant's wallet or a different-currency wallet.
- Each payout has exactly one set of sender/beneficiary snapshots and multiple processor attempts. Snapshot immutability is an application authorization/trigger policy, not simply a table FK guarantee.
- Fee calculation policy is versioned in production; each payout freezes charged `fee_amount` and `total_debit` so future pricing changes cannot rewrite history.

## Normal forms
1NF: one record per payout, wallet and processor attempt; no repeating attempt columns. 2NF: separate merchant wallets/currency tables from payout snapshots to avoid mixed keys. 3NF: processor properties and currency/country names live in their own reference tables, while `PAYOUT` stores necessary immutable amount/fee evidence and keys. Payout-parties snapshots intentionally repeat merchant-supplied names across separate requests to preserve **historical facts**, not onboard customers.

## Important gaps you should explain
- Processor selection **after debit** creates a crash window; `OUTBOX_EVENT` makes dispatch durable.
- External processor delivery can be at least once. Stable provider idempotency keys, attempt uniqueness and reconciliation are required; SQL isolation cannot make an external API atomic.
- A processor timeout means **unknown**, not failed. Do not refund unless terminal failure is definitive; a late success after refund causes monetary loss.
- `wallet.balance` needs initial funding journal alignment and routine reconciliation with ledger and external settlement reports. Multirow balanced-journal constraints need application checks or a dedicated posting procedure.
- The demo excludes FX and assumes amounts, fees and wallet debit share one currency. Each merchant holds separate currency wallets.
