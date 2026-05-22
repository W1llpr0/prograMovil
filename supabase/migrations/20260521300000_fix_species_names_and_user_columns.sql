-- Migration: Remove English-named duplicate species, ensure user columns exist
-- Date: 2026-05-21

-- Helper: null out breed on pets before we delete breeds, then reassign species.

-- Dog → Perro
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='dog'));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Perro' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='dog')
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Perro');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='dog');
DELETE FROM public.species WHERE lower(name)='dog';

-- Cat → Gato
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='cat'));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Gato' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='cat')
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Gato');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='cat');
DELETE FROM public.species WHERE lower(name)='cat';

-- Turtle/Tortoise → Tortuga
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name) IN ('turtle','tortoise')));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Tortuga' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name) IN ('turtle','tortoise'))
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Tortuga');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name) IN ('turtle','tortoise'));
DELETE FROM public.species WHERE lower(name) IN ('turtle','tortoise');

-- Bird → Ave
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='bird'));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Ave' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='bird')
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Ave');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='bird');
DELETE FROM public.species WHERE lower(name)='bird';

-- Rabbit → Conejo
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='rabbit'));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Conejo' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='rabbit')
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Conejo');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='rabbit');
DELETE FROM public.species WHERE lower(name)='rabbit';

-- Fish → Pez
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='fish'));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Pez' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='fish')
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Pez');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='fish');
DELETE FROM public.species WHERE lower(name)='fish';

-- Hamster → Hámster
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='hamster'));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Hámster' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='hamster')
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Hámster');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name)='hamster');
DELETE FROM public.species WHERE lower(name)='hamster';

-- Guinea Pig → Cobayo
UPDATE public.pets SET breed_id = NULL WHERE breed_id IN (SELECT id FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name) IN ('guinea pig','guinea_pig')));
UPDATE public.pets SET species_id = (SELECT id FROM public.species WHERE name='Cobayo' LIMIT 1)
  WHERE species_id IN (SELECT id FROM public.species WHERE lower(name) IN ('guinea pig','guinea_pig'))
    AND EXISTS (SELECT 1 FROM public.species WHERE name='Cobayo');
DELETE FROM public.breeds WHERE species_id IN (SELECT id FROM public.species WHERE lower(name) IN ('guinea pig','guinea_pig'));
DELETE FROM public.species WHERE lower(name) IN ('guinea pig','guinea_pig');

-- 2. Ensure public.users has all required columns
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS address text;
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS phone text;
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS document text;
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS profile_picture text;
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS latitude double precision;
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS longitude double precision;

-- 3. Pet delete policy
DROP POLICY IF EXISTS "Clients can delete own pets" ON public.pets;
CREATE POLICY "Clients can delete own pets" ON public.pets
  FOR DELETE USING (client_id = auth.uid());

-- 4. Breed policies for API-seeded breeds
DROP POLICY IF EXISTS "Anyone can read breeds" ON public.breeds;
CREATE POLICY "Anyone can read breeds" ON public.breeds
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Clients can insert breeds" ON public.breeds;
CREATE POLICY "Clients can insert breeds" ON public.breeds
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
