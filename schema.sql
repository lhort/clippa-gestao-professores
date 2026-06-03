-- Clippa Gestão de Professores — Schema v0
-- Execute no SQL Editor do Supabase

create extension if not exists "uuid-ossp";

create table if not exists clubs (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);

create table if not exists professors (
  id uuid primary key default gen_random_uuid(),
  club_id uuid references clubs(id) on delete cascade,
  name text not null,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists app_users (
  id uuid primary key default gen_random_uuid(),
  club_id uuid references clubs(id) on delete cascade,
  name text not null,
  role text not null check (role in ('gestor', 'professor', 'secretaria')),
  pin text not null,
  professor_id uuid references professors(id) on delete set null,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists lesson_types (
  id uuid primary key default gen_random_uuid(),
  club_id uuid references clubs(id) on delete cascade,
  name text not null,
  total_price numeric not null,
  prof_pct numeric not null default 60,
  club_pct numeric not null default 40,
  color text default '#9CA3AF',
  num_students integer default 1,
  active boolean default true,
  sort_order integer default 0,
  created_at timestamptz default now()
);

create table if not exists lessons (
  id uuid primary key default gen_random_uuid(),
  professor_id uuid references professors(id) on delete cascade,
  lesson_type_id uuid references lesson_types(id),
  date date not null,
  students text[] not null default '{}',
  total_value numeric not null,
  prof_value numeric not null,
  club_value numeric not null,
  notes text,
  created_at timestamptz default now()
);

create table if not exists financial_entries (
  id uuid primary key default gen_random_uuid(),
  professor_id uuid references professors(id) on delete cascade,
  type text not null check (type in ('extra', 'desconto', 'pagamento')),
  value numeric not null,
  date date not null,
  notes text,
  created_at timestamptz default now()
);

-- Disable RLS for v0 (auth handled at app level via PIN)
alter table clubs disable row level security;
alter table professors disable row level security;
alter table app_users disable row level security;
alter table lesson_types disable row level security;
alter table lessons disable row level security;
alter table financial_entries disable row level security;

-- Seed: initial club
insert into clubs (id, name) values
  ('a0000000-0000-0000-0000-000000000001', 'Meu Clube')
on conflict (id) do nothing;

-- Seed: gestor admin (PIN: 1234)
insert into app_users (club_id, name, role, pin) values
  ('a0000000-0000-0000-0000-000000000001', 'Admin', 'gestor', '1234')
on conflict do nothing;

-- Seed: default lesson types
insert into lesson_types (club_id, name, total_price, prof_pct, club_pct, color, num_students, sort_order) values
  ('a0000000-0000-0000-0000-000000000001', 'Individual',  95,  60, 40, '#8B5CF6', 1, 1),
  ('a0000000-0000-0000-0000-000000000001', 'Dupla',       140, 60, 40, '#3B82F6', 2, 2),
  ('a0000000-0000-0000-0000-000000000001', 'Trio',        165, 60, 40, '#F97316', 3, 3),
  ('a0000000-0000-0000-0000-000000000001', 'Quarteto',    200, 60, 40, '#10B981', 4, 4),
  ('a0000000-0000-0000-0000-000000000001', 'Escolinha',   125, 50, 50, '#EC4899', 0, 5),
  ('a0000000-0000-0000-0000-000000000001', 'Bate Bola',   30,  50, 50, '#6B7280', 0, 6)
on conflict do nothing;
