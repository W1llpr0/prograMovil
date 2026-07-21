-- Medication intake must pass through record_medication_dose so the due-time
-- check, row lock, de-duplication and schedule advancement cannot be bypassed.

revoke insert, update, delete on public.treatment_adherence
  from authenticated, anon;
grant select on public.treatment_adherence to authenticated;

