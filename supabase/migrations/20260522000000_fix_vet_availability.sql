-- Migration: 20260522000000_fix_vet_availability
-- Description: Add missing columns and unique constraint to veterinarian_availability
--              so that the vet schedule editor can upsert rows correctly.

-- 1. Add slot_duration_minutes (how long each appointment lasts, in minutes)
ALTER TABLE IF EXISTS public.veterinarian_availability
  ADD COLUMN IF NOT EXISTS slot_duration_minutes INT NOT NULL DEFAULT 30;

-- 2. Add is_active flag so vets can disable a day without deleting it
ALTER TABLE IF EXISTS public.veterinarian_availability
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- 3. Add unique constraint so that Supabase upsert (onConflict) works correctly.
--    One row per (veterinarian_id, day_of_week).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'uq_vet_availability_vet_day'
  ) THEN
    ALTER TABLE public.veterinarian_availability
      ADD CONSTRAINT uq_vet_availability_vet_day
      UNIQUE (veterinarian_id, day_of_week);
  END IF;
END $$;
