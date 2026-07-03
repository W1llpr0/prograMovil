-- Migration: 20260521000000_initial_schema
-- Description: Initial VetCare database schema with users, pets, species, breeds, and alerts

-- 1. Add missing 'document' column to users table (only if table exists)
ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS document text;
DO $$ BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    CREATE INDEX IF NOT EXISTS idx_users_document ON users(document);
  END IF;
END $$;

-- 2. Create species table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.species (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_exotic BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Create breeds table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.breeds (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  species_id BIGINT NOT NULL REFERENCES public.species(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(name, species_id)
);

-- 4. Add breed_id to pets table if it doesn't exist
ALTER TABLE IF EXISTS public.pets ADD COLUMN IF NOT EXISTS breed_id BIGINT REFERENCES public.breeds(id) ON DELETE SET NULL;

-- 5. Create epidemiological_alerts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.epidemiological_alerts (
  id BIGSERIAL PRIMARY KEY,
  disease TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  radius_km DECIMAL(8, 2) NOT NULL,
  severity_level TEXT DEFAULT 'medium',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_breeds_species_id ON public.breeds(species_id);
CREATE INDEX IF NOT EXISTS idx_pets_breed_id ON public.pets(breed_id);
CREATE INDEX IF NOT EXISTS idx_alerts_is_active ON public.epidemiological_alerts(is_active);

-- 7. Insert default species if empty
INSERT INTO public.species (name, is_exotic) VALUES 
  ('Dog', false),
  ('Cat', false),
  ('Bird', false),
  ('Rabbit', false),
  ('Hamster', false),
  ('Guinea Pig', false),
  ('Fish', false),
  ('Reptile', true),
  ('Exotic', true)
ON CONFLICT (name) DO NOTHING;

-- 8. Insert default breeds if empty
INSERT INTO public.breeds (name, species_id) VALUES
  -- Dogs (species_id = 1)
  ('Golden Retriever', 1),
  ('Labrador', 1),
  ('German Shepherd', 1),
  ('French Bulldog', 1),
  ('Poodle', 1),
  ('Beagle', 1),
  ('Bulldog', 1),
  ('Siberian Husky', 1),
  ('Dachshund', 1),
  ('Boxer', 1),
  ('Cocker Spaniel', 1),
  ('Shih Tzu', 1),
  -- Cats (species_id = 2)
  ('Persian', 2),
  ('Siamese', 2),
  ('Maine Coon', 2),
  ('Ragdoll', 2),
  ('British Shorthair', 2),
  ('Bengal', 2),
  ('Abyssinian', 2),
  ('Scottish Fold', 2),
  -- Birds (species_id = 3)
  ('Budgie', 3),
  ('Cockatiel', 3),
  ('Parrot', 3),
  ('Canary', 3),
  ('Parakeet', 3),
  -- Rabbits (species_id = 4)
  ('Lop', 4),
  ('Holland Lop', 4),
  ('Angora', 4),
  ('Rex', 4),
  -- Hamsters (species_id = 5)
  ('Syrian', 5),
  ('Roborovski', 5),
  ('Dwarf Campbell', 5),
  -- Guinea Pigs (species_id = 6)
  ('Cavies', 6),
  ('Peruvian', 6),
  ('Abyssinian', 6),
  -- Fish (species_id = 7)
  ('Goldfish', 7),
  ('Betta', 7),
  ('Tetra', 7),
  ('Guppy', 7),
  -- Reptiles (species_id = 8)
  ('Python', 8),
  ('Lizard', 8),
  ('Turtle', 8),
  ('Gecko', 8),
  ('Bearded Dragon', 8),
  -- Exotic (species_id = 9)
  ('Mixed', 9)
ON CONFLICT (name, species_id) DO NOTHING;

-- 9. Enable RLS on tables
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.breeds ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.species ENABLE ROW LEVEL SECURITY;

-- 10. Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "Users can update own data" ON public.users;
DROP POLICY IF EXISTS "Clients can view own pets" ON public.pets;
DROP POLICY IF EXISTS "Clients can insert own pets" ON public.pets;
DROP POLICY IF EXISTS "Clients can update own pets" ON public.pets;
DROP POLICY IF EXISTS "Anyone can view species" ON public.species;
DROP POLICY IF EXISTS "Anyone can view breeds" ON public.breeds;

-- 11. RLS Policies for users table
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- 12. RLS Policies for pets table
CREATE POLICY "Clients can view own pets" ON public.pets
  FOR SELECT USING (client_id = auth.uid());

CREATE POLICY "Clients can insert own pets" ON public.pets
  FOR INSERT WITH CHECK (client_id = auth.uid());

CREATE POLICY "Clients can update own pets" ON public.pets
  FOR UPDATE USING (client_id = auth.uid());

-- 13. RLS Policies for species (public read)
CREATE POLICY "Anyone can view species" ON public.species
  FOR SELECT USING (true);

-- 14. RLS Policies for breeds (public read)
CREATE POLICY "Anyone can view breeds" ON public.breeds
  FOR SELECT USING (true);

-- Verification
SELECT 'Schema initialization complete!' as status;
