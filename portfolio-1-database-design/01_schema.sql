CREATE TABLE IF NOT EXISTS business (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name STRING NOT NULL, status STRING NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','SUSPENDED'))
);
CREATE TABLE IF NOT EXISTS currency (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), code STRING NOT NULL UNIQUE, name STRING NOT NULL
);
CREATE TABLE IF NOT EXISTS country (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), iso_code STRING NOT NULL UNIQUE, name STRING NOT NULL
);
CREATE TABLE IF NOT EXISTS business_profile (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL UNIQUE REFERENCES business(id), credential_ref STRING NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS whitelisted_ip_address (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), ip_address STRING NOT NULL, UNIQUE(business_id, ip_address)
);
CREATE TABLE IF NOT EXISTS wallet (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), currency_id UUID NOT NULL REFERENCES currency(id), balance DECIMAL(20,2) NOT NULL DEFAULT 0 CHECK (balance >= 0), minimum_balance DECIMAL(20,2) NOT NULL DEFAULT 0 CHECK (minimum_balance >= 0), wallet_reference STRING NOT NULL UNIQUE,
 UNIQUE(business_id,currency_id), UNIQUE(id,business_id,currency_id)
);
CREATE TABLE IF NOT EXISTS fee_config (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), currency_id UUID NOT NULL UNIQUE REFERENCES currency(id), flat_fee DECIMAL(20,2) NOT NULL DEFAULT 0 CHECK (flat_fee >= 0), percentage_rate DECIMAL(10,6) NOT NULL DEFAULT 0 CHECK (percentage_rate >= 0)
);
CREATE TABLE IF NOT EXISTS custom_fee_config (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), currency_id UUID NOT NULL REFERENCES currency(id), flat_fee DECIMAL(20,2) NOT NULL DEFAULT 0 CHECK (flat_fee >= 0), percentage_rate DECIMAL(10,6) NOT NULL DEFAULT 0 CHECK (percentage_rate >= 0), UNIQUE(business_id,currency_id)
);
CREATE TABLE IF NOT EXISTS transfer_processor (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), processor_code STRING NOT NULL UNIQUE, currency_id UUID NOT NULL REFERENCES currency(id), country_id UUID NOT NULL REFERENCES country(id), status STRING NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','INACTIVE'))
);
CREATE TABLE IF NOT EXISTS routing_rule (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), currency_id UUID NOT NULL REFERENCES currency(id), country_id UUID NOT NULL REFERENCES country(id), processor_id UUID NOT NULL REFERENCES transfer_processor(id), priority INT NOT NULL DEFAULT 1 CHECK(priority > 0), active BOOL NOT NULL DEFAULT true,
 UNIQUE(business_id,currency_id,country_id,priority)
);
CREATE TABLE IF NOT EXISTS custom_transfer_processor (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), processor_id UUID NOT NULL REFERENCES transfer_processor(id), currency_id UUID NOT NULL REFERENCES currency(id), country_id UUID NOT NULL REFERENCES country(id), UNIQUE(business_id,processor_id,currency_id,country_id)
);
CREATE TABLE IF NOT EXISTS bank (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), country_id UUID NOT NULL REFERENCES country(id), currency_id UUID NOT NULL REFERENCES currency(id), code STRING NOT NULL, name STRING NOT NULL, UNIQUE(country_id,code)
);
CREATE TABLE IF NOT EXISTS business_blacklist (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), currency_id UUID REFERENCES currency(id), reason STRING NOT NULL
);
CREATE TABLE IF NOT EXISTS blocked_account (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), country_id UUID NOT NULL REFERENCES country(id), currency_id UUID NOT NULL REFERENCES currency(id), account_fingerprint STRING NOT NULL, reason STRING NOT NULL, UNIQUE(country_id,currency_id,account_fingerprint)
);
CREATE TABLE IF NOT EXISTS payout (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID NOT NULL REFERENCES business(id), wallet_id UUID NOT NULL, currency_id UUID NOT NULL REFERENCES currency(id), country_id UUID NOT NULL REFERENCES country(id), merchant_reference STRING NOT NULL, request_key STRING NOT NULL, request_hash STRING NOT NULL, amount DECIMAL(20,2) NOT NULL CHECK(amount > 0), fee_amount DECIMAL(20,2) NOT NULL CHECK(fee_amount >= 0), total_debit DECIMAL(20,2) NOT NULL CHECK(total_debit = amount + fee_amount), status STRING NOT NULL CHECK(status IN ('DEBITED','DISPATCHING','PENDING','SUCCEEDED','FAILED','REFUNDED','REVIEW')),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 UNIQUE(business_id,merchant_reference), UNIQUE(business_id,request_key),
 FOREIGN KEY(wallet_id,business_id,currency_id) REFERENCES wallet(id,business_id,currency_id)
);

CREATE TABLE IF NOT EXISTS payout_parties (
 payout_id UUID PRIMARY KEY REFERENCES payout(id), sender_name STRING NOT NULL, sender_reference STRING, sender_details JSONB NOT NULL DEFAULT '{}'::JSONB,
 beneficiary_name STRING NOT NULL, beneficiary_bank_code STRING, beneficiary_account_token STRING,
 beneficiary_account_last4 STRING, beneficiary_details JSONB NOT NULL DEFAULT '{}'::JSONB
);
CREATE TABLE IF NOT EXISTS payout_status_history (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payout_id UUID NOT NULL REFERENCES payout(id), status STRING NOT NULL, comment STRING, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS processor_attempt (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payout_id UUID NOT NULL REFERENCES payout(id), processor_id UUID NOT NULL REFERENCES transfer_processor(id), attempt_no INT NOT NULL CHECK(attempt_no > 0), provider_idempotency_key STRING NOT NULL, provider_reference STRING, status STRING NOT NULL CHECK(status IN ('CREATED','SUBMITTED','PENDING','SUCCEEDED','FAILED','UNKNOWN')),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(payout_id,attempt_no), UNIQUE(provider_idempotency_key)
);
CREATE TABLE IF NOT EXISTS processor_webhook (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payout_id UUID NOT NULL REFERENCES payout(id), processor_id UUID NOT NULL REFERENCES transfer_processor(id), provider_event_id STRING NOT NULL, event_type STRING NOT NULL, payload_redacted JSONB NOT NULL, received_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(processor_id,provider_event_id)
);
CREATE TABLE IF NOT EXISTS outbox_event (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payout_id UUID NOT NULL REFERENCES payout(id), event_type STRING NOT NULL, status STRING NOT NULL DEFAULT 'NEW' CHECK(status IN ('NEW','CLAIMED','DONE','RETRY')), payload JSONB NOT NULL DEFAULT '{}'::JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(payout_id,event_type)
);

CREATE TABLE IF NOT EXISTS ledger_account (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), currency_id UUID NOT NULL REFERENCES currency(id), wallet_id UUID UNIQUE REFERENCES wallet(id), account_type STRING NOT NULL CHECK(account_type IN ('MERCHANT_LIABILITY','PAYOUT_CLEARING','FEE_REVENUE','FUNDING_CLEARING')),
 account_code STRING NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS ledger_journal (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payout_id UUID REFERENCES payout(id), journal_type STRING NOT NULL CHECK(journal_type IN ('PAYOUT_DEBIT','PAYOUT_REFUND','FUNDING')), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(payout_id,journal_type)
);
CREATE TABLE IF NOT EXISTS ledger_entry (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), journal_id UUID NOT NULL REFERENCES ledger_journal(id), account_id UUID NOT NULL REFERENCES ledger_account(id), debit DECIMAL(20,2) NOT NULL DEFAULT 0 CHECK(debit >= 0), credit DECIMAL(20,2) NOT NULL DEFAULT 0 CHECK(credit >= 0), CHECK ((debit > 0 AND credit = 0) OR (credit > 0 AND debit = 0))
);

CREATE TABLE IF NOT EXISTS wallet_funding (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), wallet_id UUID NOT NULL REFERENCES wallet(id), funding_reference STRING NOT NULL UNIQUE, amount DECIMAL(20,2) NOT NULL CHECK(amount > 0), status STRING NOT NULL CHECK(status IN ('CONFIRMED','REVERSED')), created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS audit_log (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), business_id UUID REFERENCES business(id), payout_id UUID REFERENCES payout(id), action STRING NOT NULL, metadata_redacted JSONB NOT NULL DEFAULT '{}'::JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
