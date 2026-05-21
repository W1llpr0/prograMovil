-- Migration: 20260521100000_fix_data_and_alerts
-- Description: Fix breeds data using subqueries + add sample alerts + add breeds INSERT policy

-- 1. Add INSERT policy for breeds so authenticated users can create custom breeds
DROP POLICY IF EXISTS "Authenticated can insert breeds" ON public.breeds;
CREATE POLICY "Authenticated can insert breeds" ON public.breeds
  FOR INSERT TO authenticated WITH CHECK (true);

-- 2. Re-insert breeds using subqueries (avoids hardcoded ID dependency)
INSERT INTO public.breeds (name, species_id)
SELECT 'Golden Retriever', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Labrador', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'German Shepherd', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'French Bulldog', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Poodle', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Beagle', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Bulldog', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Siberian Husky', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Dachshund', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Shih Tzu', id FROM public.species WHERE name = 'Dog'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Persian', id FROM public.species WHERE name = 'Cat'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Siamese', id FROM public.species WHERE name = 'Cat'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Maine Coon', id FROM public.species WHERE name = 'Cat'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Ragdoll', id FROM public.species WHERE name = 'Cat'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'British Shorthair', id FROM public.species WHERE name = 'Cat'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Bengal', id FROM public.species WHERE name = 'Cat'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Budgie', id FROM public.species WHERE name = 'Bird'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Cockatiel', id FROM public.species WHERE name = 'Bird'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Parrot', id FROM public.species WHERE name = 'Bird'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Lop', id FROM public.species WHERE name = 'Rabbit'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Holland Lop', id FROM public.species WHERE name = 'Rabbit'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Syrian', id FROM public.species WHERE name = 'Hamster'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Roborovski', id FROM public.species WHERE name = 'Hamster'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Python', id FROM public.species WHERE name = 'Reptile'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Gecko', id FROM public.species WHERE name = 'Reptile'
ON CONFLICT (name, species_id) DO NOTHING;

INSERT INTO public.breeds (name, species_id)
SELECT 'Bearded Dragon', id FROM public.species WHERE name = 'Reptile'
ON CONFLICT (name, species_id) DO NOTHING;

-- 3. Ensure severity_level column exists (may be missing if initial migration was partial)
ALTER TABLE public.epidemiological_alerts
  ADD COLUMN IF NOT EXISTS severity_level TEXT DEFAULT 'medium';

-- Make consultation_id nullable if it exists (legacy column not in current schema)
ALTER TABLE public.epidemiological_alerts
  ALTER COLUMN consultation_id DROP NOT NULL;

-- 4. Add sample epidemiological alerts for Lima, Peru
INSERT INTO public.epidemiological_alerts (disease, latitude, longitude, radius_km, severity_level, is_active)
VALUES
  ('Parvovirus Canino', -12.0464, -77.0428, 2.5, 'high', true),
  ('Leptospirosis', -12.1000, -77.0300, 3.0, 'medium', true),
  ('Distemper', -12.0700, -77.0600, 1.5, 'high', true),
  ('Rabia', -11.9800, -77.0800, 5.0, 'critical', true)
ON CONFLICT DO NOTHING;

-- 5. Add RLS policy for alerts (public read)
DROP POLICY IF EXISTS "Anyone can view alerts" ON public.epidemiological_alerts;
CREATE POLICY "Anyone can view alerts" ON public.epidemiological_alerts
  FOR SELECT USING (true);

ALTER TABLE IF EXISTS public.epidemiological_alerts ENABLE ROW LEVEL SECURITY;

SELECT 'Data fix complete!' as status;
