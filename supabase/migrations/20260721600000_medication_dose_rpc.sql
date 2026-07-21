-- Record a medication dose atomically and advance the next due time.
-- This prevents double taps and makes the client UI deterministic.

create unique index if not exists uq_adherence_schedule_scheduled_for
  on public.treatment_adherence(schedule_id, scheduled_for)
  where scheduled_for is not null;

create or replace function public.record_medication_dose(
  p_schedule_id bigint,
  p_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  current_schedule public.medication_schedules;
  due_at timestamptz;
  next_due_at timestamptz;
  created_record public.treatment_adherence;
begin
  if auth.uid() is null then
    return jsonb_build_object(
      'success', false,
      'code', 'UNAUTHENTICATED',
      'message', 'Debes iniciar sesión.'
    );
  end if;

  select m.* into current_schedule
  from public.medication_schedules m
  where m.id = p_schedule_id
  for update;

  if current_schedule.id is null or not exists (
    select 1
    from public.consultations c
    where c.id = current_schedule.consultation_id
      and public.owns_pet(c.pet_id)
  ) then
    return jsonb_build_object(
      'success', false,
      'code', 'SCHEDULE_FORBIDDEN',
      'message', 'El tratamiento no pertenece a una de tus mascotas.'
    );
  end if;

  if not current_schedule.is_active then
    return jsonb_build_object(
      'success', false,
      'code', 'SCHEDULE_INACTIVE',
      'message', 'Este tratamiento ya no está activo.'
    );
  end if;

  due_at := coalesce(current_schedule.next_dose_at, now());
  if due_at > now() + interval '30 minutes' then
    return jsonb_build_object(
      'success', false,
      'code', 'DOSE_TOO_EARLY',
      'message', 'La siguiente dosis todavía no corresponde.',
      'data', jsonb_build_object('next_dose_at', due_at)
    );
  end if;

  insert into public.treatment_adherence (
    schedule_id, taken_at, scheduled_for, notes, created_by
  ) values (
    current_schedule.id,
    now(),
    due_at,
    nullif(trim(p_notes), ''),
    auth.uid()
  )
  returning * into created_record;

  next_due_at := greatest(due_at, now()) +
    make_interval(hours => coalesce(current_schedule.frequency_hours, 24));

  update public.medication_schedules
  set next_dose_at = next_due_at
  where id = current_schedule.id;

  return jsonb_build_object(
    'success', true,
    'code', 'DOSE_RECORDED',
    'message', 'Dosis registrada correctamente.',
    'data', jsonb_build_object(
      'adherence_id', created_record.id,
      'taken_at', created_record.taken_at,
      'scheduled_for', created_record.scheduled_for,
      'next_dose_at', next_due_at
    )
  );
exception
  when unique_violation then
    return jsonb_build_object(
      'success', false,
      'code', 'DOSE_ALREADY_RECORDED',
      'message', 'Esta dosis ya fue registrada.'
    );
  when others then
    return jsonb_build_object(
      'success', false,
      'code', 'DOSE_ERROR',
      'message', 'No se pudo registrar la dosis.'
    );
end;
$$;

revoke execute on function public.record_medication_dose(bigint, text)
  from public, anon;
grant execute on function public.record_medication_dose(bigint, text)
  to authenticated;
