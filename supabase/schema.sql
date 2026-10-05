-- Grão — tabelas do Supabase (CP5)
-- Cole este arquivo inteiro em: Supabase > SQL Editor > New query > Run

create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  amount      numeric(12, 2) not null check (amount > 0),
  is_expense  boolean not null default true,
  category    text not null,
  date        timestamptz not null default now(),
  note        text,
  created_at  timestamptz not null default now()
);

create table if not exists public.goals (
  category       text primary key,
  monthly_limit  numeric(12, 2) not null check (monthly_limit > 0)
);

-- Protótipo: o app ainda não tem login (isso entra no CP6),
-- então as políticas liberam leitura e escrita para a chave anon.
-- Antes de publicar de verdade, troque por políticas por usuário.
alter table public.transactions enable row level security;
alter table public.goals enable row level security;

drop policy if exists "prototipo_transactions_all" on public.transactions;
create policy "prototipo_transactions_all"
  on public.transactions for all
  using (true) with check (true);

drop policy if exists "prototipo_goals_all" on public.goals;
create policy "prototipo_goals_all"
  on public.goals for all
  using (true) with check (true);
