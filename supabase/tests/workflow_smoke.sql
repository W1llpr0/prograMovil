\set ON_ERROR_STOP on

insert into auth.users (id, email, raw_user_meta_data) values
  ('11111111-1111-1111-1111-111111111111', 'cliente@vetcare.test',
   '{"first_name":"Diego","last_name":"Martínez","role":"client","document":"70000001"}'),
  ('22222222-2222-2222-2222-222222222222', 'vet@vetcare.test',
   '{"first_name":"Rodrigo","last_name":"Paz","role":"veterinarian","document":"45892"}');

insert into public.pets (client_id, name, species_id, breed_id, sex_code, birth_date, weight_kg)
select
  '11111111-1111-1111-1111-111111111111',
  'Max',
  s.id,
  (select b.id from public.breeds b where b.species_id = s.id order by b.id limit 1),
  'M',
  current_date - interval '3 years',
  25.5
from public.species s where s.name = 'Perro'
limit 1;

select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);
select set_config('request.jwt.claim.role', 'authenticated', false);

do $$
declare
  pet_id bigint;
  vet_id uuid;
  specialty_id bigint;
  next_monday date;
  booked jsonb;
  v_consultation_id bigint;
  started jsonb;
  completed jsonb;
  reviewed jsonb;
begin
  select id into pet_id from public.pets where name = 'Max';
  select id into vet_id from public.veterinarians
    where user_id = '22222222-2222-2222-2222-222222222222';
  select id into specialty_id from public.specialties where name = 'Medicina General';
  next_monday := current_date +
    case when extract(dow from current_date)::integer = 1
      then 7 else (8 - extract(dow from current_date)::integer) % 7 end;

  booked := public.book_consultation(
    pet_id,
    vet_id,
    specialty_id,
    (next_monday + time '10:00') at time zone 'America/Lima',
    'Chequeo anual'
  );
  if booked->>'success' <> 'true' then
    raise exception 'booking failed: %', booked;
  end if;
  v_consultation_id := (booked->'data'->>'id')::bigint;

  perform set_config('request.jwt.claim.sub', '22222222-2222-2222-2222-222222222222', false);
  started := public.start_consultation(v_consultation_id);
  if started->>'success' <> 'true' then
    raise exception 'start failed: %', started;
  end if;

  completed := public.complete_consultation(
    v_consultation_id,
    'Otitis externa',
    'Limpieza y gotas óticas',
    'Control en siete días',
    true,
    '{"weight_kg":25.5,"temperature_c":38.5}',
    '[{"name":"Gotas óticas","dosage":"3 gotas","frequency_hours":8,"start_date":"2026-07-20","end_date":"2026-07-27"}]'
  );
  if completed->>'success' <> 'true' then
    raise exception 'completion failed: %', completed;
  end if;

  perform set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);
  reviewed := public.submit_review(v_consultation_id, 5, 'Excelente atención');
  if reviewed->>'success' <> 'true' then
    raise exception 'review failed: %', reviewed;
  end if;

  if not exists (select 1 from public.medication_schedules m where m.consultation_id = v_consultation_id) then
    raise exception 'medication schedule was not created';
  end if;
  if not exists (select 1 from public.epidemiological_alerts a where a.consultation_id = v_consultation_id) then
    raise exception 'epidemiological alert was not created';
  end if;
  if (select char_length(c.integrity_hash) from public.consultations c where c.id = v_consultation_id) <> 64 then
    raise exception 'invalid SHA-256 hash';
  end if;
end $$;

select
  (select count(*) from public.users) as users,
  (select count(*) from public.pets) as pets,
  (select count(*) from public.consultations) as consultations,
  (select count(*) from public.medication_schedules) as medications,
  (select count(*) from public.epidemiological_alerts) as alerts,
  (select count(*) from public.reviews) as reviews;
