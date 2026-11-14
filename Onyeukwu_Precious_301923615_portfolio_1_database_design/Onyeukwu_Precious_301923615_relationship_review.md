# Relationship review — CockroachDB constraints

## Foreign keys

| Child table | Child column | Parent reference | Constraint name |
|---|---|---|---|
| `business` | `country_fk` | `country.id` | `fk_business_country_country` |
| `business_blacklist` | `business_fk` | `business.id` | `fk_business_blacklist_business_business` |
| `business_blacklist` | `currency_fk` | `currency.id` | `fk_business_blacklist_currency_currency` |
| `business_profile` | `business_fk` | `business.id` | `fk_business_profile_business_business` |
| `currency` | `country_fk` | `country.id` | `fk_currency_country_country` |
| `banks` | `country_fk` | `country.id` | `fk_banks_country_country` |
| `banks` | `currency_fk` | `currency.id` | `fk_banks_currency_currency` |
| `blocked_accounts` | `currency_fk` | `currency.id` | `fk_blocked_accounts_currency_currency` |
| `blocked_accounts` | `country_fk` | `country.id` | `fk_blocked_accounts_country_country` |
| `fee_configs` | `currency_fk` | `currency.id` | `fk_fee_configs_currency_currency` |
| `business_custom_fees` | `currency_fk` | `currency.id` | `fk_business_custom_fees_currency_currency` |
| `wallets` | `business_fk` | `business.id` | `fk_wallets_business_business` |
| `wallets` | `currency_fk` | `currency.id` | `fk_wallets_currency_currency` |
| `wallets` | `country_fk` | `country.id` | `fk_wallets_country_country` |
| `wallet_funding` | `business_fk` | `business.id` | `fk_wallet_funding_business_business` |
| `wallet_funding` | `currency_fk` | `currency.id` | `fk_wallet_funding_currency_currency` |
| `wallet_funding` | `wallet_fk` | `wallets.id` | `fk_wallet_funding_wallet_wallets` |
| `beneficiary` | `business_fk` | `business.id` | `fk_beneficiary_business_business` |
| `beneficiary` | `country_fk` | `country.id` | `fk_beneficiary_country_country` |
| `transactions` | `business_fk` | `business.id` | `fk_transactions_business_business` |
| `transactions` | `currency_fk` | `currency.id` | `fk_transactions_currency_currency` |
| `transactions` | `beneficiary_fk` | `beneficiary.id` | `fk_transactions_beneficiary_beneficiary` |
| `transactions` | `bank_fk` | `banks.id` | `fk_transactions_bank_banks` |
| `transactions` | `country_fk` | `country.id` | `fk_transactions_country_country` |
| `transactions` | `sender_fk` | `sender.id` | `fk_transactions_sender_sender` |
| `transactions` | `voucher_fk` | `voucher.id` | `fk_transactions_voucher_voucher` |
| `voucher` | `business_fk` | `business.id` | `fk_voucher_business_business` |
| `voucher` | `currency_fk` | `currency.id` | `fk_voucher_currency_currency` |
| `voucher` | `country_fk` | `country.id` | `fk_voucher_country_country` |
| `whitelisted_ip_address` | `business_fk` | `business.id` | `fk_whitelisted_ip_address_business_business` |
| `routing_rule` | `business_fk` | `business.id` | `fk_routing_rule_business_business` |
| `routing_rule` | `currency_fk` | `currency.id` | `fk_routing_rule_currency_currency` |



- `business.profile_fk` → `business_profile.id`
- `country.currency_fk` → `currency.id`
- `fee_configs.currency_id` → `currency.id`
- `business_custom_fees.business_fk` → `business_profile.id` (**note:** source uses `business_profile`, not `business`)
- `transfer_processor.currency_fk` → `currency.id`
- `transfer_processor.country_fk` → `country.id`
- `custom_transfer_processor.processor_fk` → `transfer_processor.id`
- `custom_transfer_processor.country_fk` → `country.id`
- `custom_transfer_processor.business_fk` → `business.id`
- `custom_transfer_processor.currency_fk` → `currency.id`
- `risk_router.country_fk` → `country.id`
- `risk_router.currency_fk` → `currency.id`
- `audit_log.business_fk` → `business.id`

## Deployment and modelling implications

1. **Mutual dependencies.** `business.profile_fk` → `business_profile.id` and `business_profile.business_fk` → `business.id` are circular. Likewise, `country.currency_fk` → `currency.id` and `currency.country_fk` → `country.id`. Tables are created first; all FKs are applied afterward. Seed records using nullable references first, then populate the reciprocal references with `UPDATE`.
2. **Data migration.** Existing non-null values that reference missing parents must be cleaned or remapped before the `ALTER TABLE ... ADD CONSTRAINT` statements can succeed. Foreign keys permit `NULL` unless the column is also `NOT NULL`.
3. **Referential actions.** No cascading deletes are configured; the defaults protect parent rows referenced by child rows.
4. **Relationship cardinality.** Mermaid uses a broad parent-to-zero-or-many link for all constraints. Uniqueness (`business.profile_fk`, `country.currency_fk`) may restrict the actual cardinality; the SQL is authoritative.
5. **No cross-field consistency guarantee.** Separate FKs do not prove that `wallet_funding.business_fk` equals the associated `wallets.business_fk`, or that its currency matches the wallet currency.

## Test procedure

Run `06_orphan_precheck.sql` before applying FKs to an already-populated database. For a clean assessment database, run `01_schema_cockroachdb.sql` followed by `03_seed.sql`, then `04_verification.sql`.