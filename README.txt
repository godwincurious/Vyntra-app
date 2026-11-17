VYNTRA — PHASE 2 FOUNDATION
============================

WHAT THIS UPDATE ADDS
- Supabase email/password sign-up and sign-in UI.
- Existing Vyntra demo screens and navigation are retained.
- Supabase SQL foundation for profiles, NGN/USD/GBP/EUR wallet records,
  transaction history, row-level security (RLS), and a new-user trigger.
- Safe browser configuration template (public anon key only).

IMPORTANT LIMITATIONS
This is an authentication and database foundation, not a live fintech launch.
The existing dashboard still contains DEMO balances, prices and simulated actions.
No real funds can be deposited, withdrawn, transferred or converted.
No virtual phone number, bank account, crypto asset or gift card is issued.
The SQL intentionally does not let a browser change wallet balances or create
financial transactions. Those actions must be implemented on a trusted backend
after regulated partner onboarding, security review and compliance approval.

ANDROID SETUP
1. Extract this ZIP on your Android phone.
2. Create a Supabase project at https://supabase.com (free tier availability/limits may change).
3. In Supabase, open Project Settings > API. Copy the Project URL and anon/public key.
4. Open config.js in a text editor. Replace the two YOUR_ placeholders.
   The anon/public key is intended for browser use with RLS enabled.
   NEVER paste the service_role key, database password, or provider API secrets.
5. In Supabase Dashboard > SQL Editor, create a new query.
6. Paste all contents of supabase_schema.sql and run it.
7. Host the Vyntra_App folder on an HTTPS static host, then open the hosted app.
   Authentication callbacks and email confirmation must be configured in Supabase
   Authentication > URL Configuration to include your hosted app URL.
8. Create a test account and verify that a profile and four pending wallet records
   appear in the Supabase Table Editor.

LOCAL FILE NOTE
Some mobile file viewers block authentication redirects or browser storage from
local file:// pages. For reliable sign-in, host the app over HTTPS.

NEXT PRODUCTION BUILD
- Trusted server/API layer and secret management.
- Admin role provisioning outside the client.
- Payment gateway and webhook verification.
- Provider integrations for virtual numbers, accounts, crypto and gift cards.
- KYC/AML, fraud controls, reconciliation, audit logs, privacy policy and terms.
- Independent security testing before handling customer funds or identity documents.

Never use real customer money or identity documents in this prototype.
