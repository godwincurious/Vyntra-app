-- VYNTRA PHASE 2 DATABASE FOUNDATION
-- Run this in Supabase Dashboard > SQL Editor.
-- This creates identity/profile, wallet and transaction records.
-- It does NOT create real money, issue accounts, execute trades or integrate providers.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  role text not null default 'customer' check (role in ('customer','support','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  currency char(3) not null check (currency in ('NGN','USD','GBP','EUR')),
  balance numeric(20,2) not null default 0 check (balance >= 0),
  status text not null default 'pending' check (status in ('pending','active','frozen','closed')),
  created_at timestamptz not null default now(),
  unique(user_id, currency)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  wallet_id uuid references public.wallets(id) on delete set null,
  type text not null check (type in ('deposit','withdrawal','transfer','conversion','purchase','refund','adjustment')),
  currency char(3) not null check (currency in ('NGN','USD','GBP','EUR')),
  amount numeric(20,2) not null check (amount > 0),
  status text not null default 'pending' check (status in ('pending','processing','successful','failed','reversed')),
  reference text unique,
  description text,
  created_at timestamptz not null default now()
);

create index if not exists transactions_user_created_idx
  on public.transactions(user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.wallets enable row level security;
alter table public.transactions enable row level security;

-- Users can read/update their own profile, but cannot change their role.
drop policy if exists "profile read own" on public.profiles;
create policy "profile read own" on public.profiles
  for select to authenticated using (auth.uid() = id);
drop policy if exists "profile update own basic fields" on public.profiles;
create policy "profile update own basic fields" on public.profiles
  for update to authenticated using (auth.uid() = id)
  with check (auth.uid() = id and role = 'customer');

-- Customers can only read their own wallet and transaction records.
-- No browser-side insert/update/delete policies are provided for financial records.
drop policy if exists "wallet read own" on public.wallets;
create policy "wallet read own" on public.wallets
  for select to authenticated using (auth.uid() = user_id);
drop policy if exists "transaction read own" on public.transactions;
create policy "transaction read own" on public.transactions
  for select to authenticated using (auth.uid() = user_id);

-- Automatically create profile and empty currency wallet records after sign-up.
create or replace function public.handle_new_vyntra_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name',''), new.email)
  on conflict (id) do nothing;

  insert into public.wallets (user_id, currency, status)
  values
    (new.id, 'NGN', 'pending'),
    (new.id, 'USD', 'pending'),
    (new.id, 'GBP', 'pending'),
    (new.id, 'EUR', 'pending')
  on conflict (user_id, currency) do nothing;

  return new;
end;
$$;

drop trigger if exists on_vyntra_auth_user_created on auth.users;
create trigger on_vyntra_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_vyntra_user();

-- IMPORTANT:
-- Do not grant customers direct balance editing or transaction creation.
-- Future money movement must happen through a trusted server/Edge Function,
-- verified payment/provider webhooks, idempotency checks and an auditable ledger.
-- Do not set a customer's role to admin from the client.
