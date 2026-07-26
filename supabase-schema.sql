-- ============================================================
-- Wellness Monitoring App - databázové schéma pro Supabase
-- ============================================================
-- Postup: Supabase Dashboard -> SQL Editor -> vlož celý tento
-- soubor -> Run.
-- ============================================================

-- Tabulka profilů (propojená s Supabase Auth uživateli)
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  role text not null default 'client' check (role in ('client', 'coach')),
  created_at timestamptz default now()
);

-- Tabulka záznamů (denní wellness i RPE po tréninku)
create table if not exists checkins (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users on delete cascade not null,
  created_at timestamptz default now(),
  type text not null check (type in ('daily', 'training')),
  -- denní wellness (1-10)
  sleep_quality int check (sleep_quality between 1 and 10),
  soreness int check (soreness between 1 and 10),
  mood int check (mood between 1 and 10),
  stress int check (stress between 1 and 10),
  readiness int check (readiness between 1 and 10),
  -- po tréninku
  rpe int check (rpe between 1 and 10),
  duration_min int,
  notes text
);

-- Zapnutí Row Level Security (klíčové pro soukromí dat)
alter table profiles enable row level security;
alter table checkins enable row level security;

-- --- Policies: profiles ---

drop policy if exists "profiles_select_own" on profiles;
create policy "profiles_select_own"
  on profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_select_coach" on profiles;
create policy "profiles_select_coach"
  on profiles for select
  using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'coach')
  );

drop policy if exists "profiles_insert_own" on profiles;
create policy "profiles_insert_own"
  on profiles for insert
  with check (auth.uid() = id);

-- --- Policies: checkins ---

drop policy if exists "checkins_insert_own" on checkins;
create policy "checkins_insert_own"
  on checkins for insert
  with check (auth.uid() = user_id);

drop policy if exists "checkins_select_own" on checkins;
create policy "checkins_select_own"
  on checkins for select
  using (auth.uid() = user_id);

drop policy if exists "checkins_select_coach" on checkins;
create policy "checkins_select_coach"
  on checkins for select
  using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'coach')
  );

-- ============================================================
-- DŮLEŽITÉ - poslední krok po nasazení:
-- Až se zaregistruješ jako první uživatel (ty, kouč), spusť
-- tento příkaz (nahraď TVUJ_EMAIL@... svým emailem), aby tvůj
-- účet měl práva vidět všechny klienty:
--
-- update profiles set role = 'coach'
-- where id = (select id from auth.users where email = 'TVUJ_EMAIL@example.com');
-- ============================================================
