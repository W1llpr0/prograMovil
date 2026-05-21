-- =============================================================
-- VetCare — Supabase PostgreSQL Init Script
-- Run this in the Supabase SQL editor for your project.
-- =============================================================

-- ── EXTENSIONS ────────────────────────────────────────────────
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ── ENUMS ─────────────────────────────────────────────────────
create type user_role as enum ('client', 'veterinarian');
create type consultation_status as enum ('scheduled', 'completed', 'cancelled');

-- ── USERS ─────────────────────────────────────────────────────
create table if not exists users (
  id          uuid primary key default uuid_generate_v4(),
  email       text not null unique,
  first_name  text not null,
  last_name   text not null,
  phone       text,
  document    text,
  address     text,
  profile_picture text,
  latitude    double precision,
  longitude   double precision,
  role        user_role not null default 'client',
  created_at  timestamptz not null default now()
);

-- Auto-insert user row when a new Supabase Auth user signs up
create or replace function handle_new_auth_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_role user_role := 'client';
begin
  -- Avoid casting inside coalesce which can throw when enum value is unexpected
  if (new.raw_user_meta_data->>'role') = 'veterinarian' then
    v_role := 'veterinarian';
  else
    v_role := 'client';
  end if;

  insert into public.users (id, email, first_name, last_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    v_role
  )
  on conflict (id) do nothing;

  if v_role = 'client' then
    insert into public.clients (user_id) values (new.id) on conflict do nothing;
  else
    insert into public.veterinarians (user_id) values (new.id) on conflict do nothing;
  end if;

  return new;
exception when others then
  -- Never let profile-creation errors block authentication
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_auth_user();

-- ── CLIENTS ───────────────────────────────────────────────────
create table if not exists clients (
  id       uuid primary key default uuid_generate_v4(),
  user_id  uuid not null unique references users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ── VETERINARIANS ─────────────────────────────────────────────
create table if not exists veterinarians (
  id               uuid primary key default uuid_generate_v4(),
  user_id          uuid not null unique references users(id) on delete cascade,
  license_number   text,
  created_at       timestamptz not null default now()
);

-- ── SPECIALTIES ───────────────────────────────────────────────
create table if not exists specialties (
  id   serial primary key,
  name text not null unique
);

-- ── VETERINARIAN → SPECIALTY (M:N) ────────────────────────────
create table if not exists veterinarian_specialties (
  veterinarian_id uuid references veterinarians(id) on delete cascade,
  specialty_id    int  references specialties(id) on delete cascade,
  primary key (veterinarian_id, specialty_id)
);

-- ── VET AVAILABILITY ──────────────────────────────────────────
create table if not exists veterinarian_availability (
  id              serial primary key,
  veterinarian_id uuid not null references veterinarians(id) on delete cascade,
  day_of_week     int not null check (day_of_week between 0 and 6), -- 0=Sun
  start_time      time not null,
  end_time        time not null
);

-- ── SPECIES ───────────────────────────────────────────────────
create table if not exists species (
  id        serial primary key,
  name      text not null unique,
  is_exotic boolean not null default false
);

-- ── BREEDS ────────────────────────────────────────────────────
create table if not exists breeds (
  id         serial primary key,
  name       text not null,
  species_id int not null references species(id) on delete cascade,
  unique (name, species_id)
);

-- ── PETS ──────────────────────────────────────────────────────
create table if not exists pets (
  id         serial primary key,
  client_id  uuid not null references clients(user_id) on delete cascade,
  name       text not null,
  species_id int not null references species(id),
  breed_id   int references breeds(id),
  sex_code   char(1) check (sex_code in ('M','F')),
  birth_date date,
  weight_kg  numeric(6,2),
  microchip  text unique,
  photo_url  text,
  is_exotic  boolean not null default false,
  created_at timestamptz not null default now()
);

-- ── CONSULTATIONS ─────────────────────────────────────────────
create table if not exists consultations (
  id                serial primary key,
  pet_id            int not null references pets(id) on delete cascade,
  veterinarian_id   uuid not null references veterinarians(id),
  scheduled_at      timestamptz not null,
  reason            text,
  diagnosis         text,
  treatment         text,
  notes             text,
  status            consultation_status not null default 'scheduled',
  is_contagious     boolean not null default false,
  integrity_hash    text,          -- SHA-256 of id|diagnosis|treatment
  created_at        timestamptz not null default now()
);

-- ── CONSULTATION DOCUMENTS ────────────────────────────────────
create table if not exists consultation_documents (
  id              serial primary key,
  consultation_id int not null references consultations(id) on delete cascade,
  file_url        text not null,
  doc_type        text not null default 'attachment',
  uploaded_at     timestamptz not null default now()
);

-- ── MEDICATION SCHEDULES ──────────────────────────────────────
create table if not exists medication_schedules (
  id               serial primary key,
  consultation_id  int not null references consultations(id) on delete cascade,
  medication_name  text not null,
  dosage           text,
  frequency        text,  -- e.g. 'every 8 hours'
  start_date       date not null,
  end_date         date,
  is_active        boolean not null default true,
  created_at       timestamptz not null default now()
);

-- ── TREATMENT ADHERENCE ───────────────────────────────────────
create table if not exists treatment_adherence (
  id          serial primary key,
  schedule_id int not null references medication_schedules(id) on delete cascade,
  taken_at    timestamptz not null default now(),
  notes       text
);

-- ── EPIDEMIOLOGICAL ALERTS ────────────────────────────────────
create table if not exists epidemiological_alerts (
  id              serial primary key,
  consultation_id int not null references consultations(id) on delete cascade,
  disease         text not null,
  latitude        double precision,
  longitude       double precision,
  radius_km       numeric(6,2) not null default 5.0,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now()
);

-- ── MORPHOLOGICAL RECORDS (Exotic) ────────────────────────────
create table if not exists morphological_records (
  id              serial primary key,
  pet_id          int not null references pets(id) on delete cascade,
  recorded_at     timestamptz not null default now(),
  length_cm       numeric(6,2),
  weight_kg       numeric(6,3),
  scale_condition text,
  color_pattern   text,
  notes           text
);

-- ── LEGAL DOCUMENTS (CITES) ───────────────────────────────────
create table if not exists legal_documents (
  id          serial primary key,
  pet_id      int not null references pets(id) on delete cascade,
  doc_type    text not null, -- 'CITES', 'import_permit', 'ownership'
  file_url    text not null,
  expires_at  date,
  notes       text,
  uploaded_at timestamptz not null default now()
);

-- =============================================================
-- TRIGGERS
-- =============================================================

-- Trigger 1: When a consultation treatment is inserted (becomes completed),
--            auto-create medication_schedule rows from treatment text.
--            (This is a simplified version — a real implementation would
--             parse treatment instructions from the Edge Function layer.
--             Here we insert a single schedule row as a placeholder.)
create or replace function auto_create_medication_schedule()
returns trigger language plpgsql as $$
begin
  if NEW.status = 'completed' and NEW.treatment is not null and
     (OLD.treatment is null or OLD.status <> 'completed') then
    insert into medication_schedules (consultation_id, medication_name, start_date)
    values (NEW.id, 'See treatment: ' || left(NEW.treatment, 60), current_date);
  end if;
  return NEW;
end;
$$;

drop trigger if exists trg_auto_medication on consultations;
create trigger trg_auto_medication
  after update on consultations
  for each row execute function auto_create_medication_schedule();

-- Trigger 2: When is_contagious = true, auto-insert epidemiological alert.
create or replace function auto_epidemiological_alert()
returns trigger language plpgsql as $$
declare
  v_lat double precision;
  v_lng double precision;
begin
  if NEW.is_contagious = true and (OLD.is_contagious = false or OLD.is_contagious is null) then
    -- Fetch owner's coordinates
    select u.latitude, u.longitude
    into v_lat, v_lng
    from pets p
    join clients c on c.user_id = p.client_id
    join users u on u.id = c.user_id
    where p.id = NEW.pet_id;

    insert into epidemiological_alerts (consultation_id, disease, latitude, longitude)
    values (
      NEW.id,
      coalesce(NEW.diagnosis, 'Unknown disease'),
      v_lat,
      v_lng
    );
  end if;
  return NEW;
end;
$$;

drop trigger if exists trg_epidemiological_alert on consultations;
create trigger trg_epidemiological_alert
  after update on consultations
  for each row execute function auto_epidemiological_alert();

-- =============================================================
-- ROW LEVEL SECURITY
-- =============================================================

alter table users enable row level security;
alter table clients enable row level security;
alter table veterinarians enable row level security;
alter table pets enable row level security;
alter table consultations enable row level security;
alter table medication_schedules enable row level security;
alter table treatment_adherence enable row level security;
alter table epidemiological_alerts enable row level security;
alter table morphological_records enable row level security;
alter table legal_documents enable row level security;
alter table species enable row level security;
alter table breeds enable row level security;

-- Users: everyone can read species/breeds; auth users can read/write own data
create policy "users_own_profile" on users
  for all using (auth.uid() = id);

-- Clients: own profile
create policy "clients_own" on clients
  for all using (auth.uid() = user_id);

-- Vets: own profile
create policy "vets_own" on veterinarians
  for all using (auth.uid() = user_id);

-- Pets: clients own their pets; vets can read all pets
create policy "pets_client_owns" on pets
  for all using (auth.uid() = client_id);

create policy "pets_vet_reads" on pets
  for select using (
    exists (select 1 from veterinarians where user_id = auth.uid())
  );

-- Consultations: client sees own pet's consultations; vet sees own appointments
create policy "consultations_client" on consultations
  for select using (
    exists (select 1 from pets where id = pet_id and client_id = auth.uid())
  );

create policy "consultations_vet" on consultations
  for all using (auth.uid() = veterinarian_id);

-- Medication schedules: accessible if you can access the parent consultation
create policy "med_schedule_accessible" on medication_schedules
  for select using (
    exists (
      select 1 from consultations c
      join pets p on p.id = c.pet_id
      where c.id = consultation_id
        and (p.client_id = auth.uid() or c.veterinarian_id = auth.uid())
    )
  );

create policy "med_schedule_vet_write" on medication_schedules
  for insert with check (
    exists (select 1 from consultations where id = consultation_id and veterinarian_id = auth.uid())
  );

-- Treatment adherence: client marks their own
create policy "adherence_client" on treatment_adherence
  for all using (
    exists (
      select 1 from medication_schedules ms
      join consultations c on c.id = ms.consultation_id
      join pets p on p.id = c.pet_id
      where ms.id = schedule_id and p.client_id = auth.uid()
    )
  );

-- Epidemiological alerts: all authenticated users can read
create policy "alerts_read_all" on epidemiological_alerts
  for select using (auth.uid() is not null);

-- Morphological records: client owns; vet writes
create policy "morpho_client" on morphological_records
  for select using (
    exists (select 1 from pets where id = pet_id and client_id = auth.uid())
  );

create policy "morpho_vet_write" on morphological_records
  for insert with check (
    exists (select 1 from veterinarians where user_id = auth.uid())
  );

-- Legal documents: client owns their pet's docs
create policy "legal_docs_client" on legal_documents
  for all using (
    exists (select 1 from pets where id = pet_id and client_id = auth.uid())
  );

-- Species and breeds: readable by all authenticated users
create policy "species_read" on species for select using (auth.uid() is not null);
create policy "breeds_read" on breeds for select using (auth.uid() is not null);

-- =============================================================
-- SEED DATA
-- =============================================================

-- Species
insert into species (name, is_exotic) values
  ('Dog', false),
  ('Cat', false),
  ('Bird', false),
  ('Rabbit', false),
  ('Hamster', false),
  ('Turtle', true),
  ('Snake', true),
  ('Lizard', true),
  ('Fish', false),
  ('Guinea Pig', false)
on conflict (name) do nothing;

-- Breeds
insert into breeds (name, species_id) values
  ('Labrador Retriever', (select id from species where name='Dog')),
  ('Golden Retriever',   (select id from species where name='Dog')),
  ('Bulldog',            (select id from species where name='Dog')),
  ('German Shepherd',    (select id from species where name='Dog')),
  ('Mixed Breed',        (select id from species where name='Dog')),
  ('Persian',            (select id from species where name='Cat')),
  ('Siamese',            (select id from species where name='Cat')),
  ('Maine Coon',         (select id from species where name='Cat')),
  ('Mixed Breed',        (select id from species where name='Cat')),
  ('Canary',             (select id from species where name='Bird')),
  ('Parakeet',           (select id from species where name='Bird')),
  ('Guppy',              (select id from species where name='Fish')),
  ('Neocaridina',        (select id from species where name='Fish')),
  ('Mata Mata',          (select id from species where name='Turtle')),
  ('Red-Eared Slider',   (select id from species where name='Turtle'))
on conflict do nothing;

-- Specialties
insert into specialties (name) values
  ('General Practice'),
  ('Surgery'),
  ('Dentistry'),
  ('Exotic Animals'),
  ('Dermatology'),
  ('Cardiology'),
  ('Ophthalmology')
on conflict (name) do nothing;

-- =============================================================
-- DEMO USERS  (Replace UUIDs after creating accounts in Auth)
-- Matias as client:
--   1. Create account via app with email matias@vetcare.app / Demo1234!
--   2. The trigger will auto-insert into users and clients tables.
--
-- Sample pets for Matias (insert after auth user exists):
-- =============================================================
-- 
-- INSERT SAMPLE PETS (run after Matias registers via the app):
--
-- insert into pets (client_id, name, species_id, birth_date, is_exotic)
-- values (
--   '<matias_user_id>',
--   'Mata Mata',
--   (select id from species where name = 'Turtle'),
--   '2020-03-15',
--   true
-- );
--
-- insert into morphological_records (pet_id, length_cm, weight_kg, scale_condition, color_pattern)
-- values (
--   (select id from pets where name = 'Mata Mata' limit 1),
--   32.5,
--   1.8,
--   'Good — no abrasions',
--   'Brown-grey camouflage with leaf-shaped head'
-- );
--
-- insert into pets (client_id, name, species_id, is_exotic)
-- values (
--   '<matias_user_id>',
--   'Nano Tank',
--   (select id from species where name = 'Fish'),
--   false
-- );
-- NOTE: Add 3F+3M Guppies and Blue Diamond Neocaridina shrimp as
--       separate pet entries under "Nano Tank" species.
