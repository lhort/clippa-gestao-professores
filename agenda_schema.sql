-- Clippa Agenda — Migration
-- Execute no SQL Editor do Supabase APÓS o schema.sql principal

-- WhatsApp no professor
alter table professors add column if not exists whatsapp text;

-- Slug no clube (para URL pública)
alter table clubs add column if not exists slug text;
update clubs set slug = lower(replace(name, ' ', '')) where slug is null;

-- Agenda padrão (horários recorrentes por dia da semana)
create table if not exists agenda_padrao (
  id uuid primary key default gen_random_uuid(),
  professor_id uuid references professors(id) on delete cascade,
  day_of_week integer not null check (day_of_week between 0 and 6), -- 0=dom, 1=seg...6=sab
  start_time time not null,
  end_time time not null,
  slot_minutes integer not null default 60,
  active boolean default true,
  created_at timestamptz default now()
);

-- Agenda pontual (bloqueios ou disponibilidades extras por data específica)
create table if not exists agenda_pontual (
  id uuid primary key default gen_random_uuid(),
  professor_id uuid references professors(id) on delete cascade,
  date date not null,
  type text not null check (type in ('bloqueado', 'disponivel')),
  start_time time,
  end_time time,
  notes text,
  created_at timestamptz default now()
);

-- Reservas
create table if not exists reservas (
  id uuid primary key default gen_random_uuid(),
  professor_id uuid references professors(id) on delete cascade,
  club_id uuid references clubs(id) on delete cascade,
  lesson_type_id uuid references lesson_types(id),
  date date not null,
  time time not null,
  student_name text not null,
  student_phone text not null,
  status text not null default 'pendente' check (status in ('pendente','confirmada','recusada','cancelada')),
  notes text,
  created_at timestamptz default now()
);

-- Disable RLS
alter table agenda_padrao disable row level security;
alter table agenda_pontual disable row level security;
alter table reservas disable row level security;
