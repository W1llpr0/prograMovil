-- ARCHIVO HISTORICO: NO USAR PARA INSTALACIONES NUEVAS.
--
-- El esquema vigente se encuentra en supabase/migrations y debe aplicarse en
-- orden alfabetico. Consulta supabase/README.md para el despliegue y el contrato
-- de entradas/salidas. Este archivo se conserva solo para rastrear la version
-- antigua del proyecto.

-- VetCare Complete Database Schema (legacy)

-- 1. Add missing 'document' column to users table
ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS document text;
CREATE INDEX IF NOT EXISTS idx_users_document ON users(document);

-- 2. Ensure species table exists
CREATE TABLE IF NOT EXISTS species (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_exotic BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Ensure breeds table exists  
CREATE TABLE IF NOT EXISTS breeds (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  species_id INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(name, species_id)
);

-- 4. Ensure pets table has breed_id properly set up
ALTER TABLE IF EXISTS pets ADD COLUMN IF NOT EXISTS breed_id INTEGER REFERENCES breeds(id) ON DELETE SET NULL;

-- 5. Insert default species if they don't exist
INSERT INTO species (name, is_exotic) VALUES 
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

-- 6. Insert default breeds if they don't exist
INSERT INTO breeds (name, species_id) VALUES
  ('Golden Retriever', 1),
  ('Labrador', 1),
  ('German Shepherd', 1),
  ('French Bulldog', 1),
  ('Poodle', 1),
  ('Beagle', 1),
  ('Bulldog', 1),
  ('Siberian Husky', 1),
  ('Dachshund', 1),
  ('Persian', 2),
  ('Siamese', 2),
  ('Maine Coon', 2),
  ('Ragdoll', 2),
  ('British Shorthair', 2),
  ('Bengal', 2),
  ('Budgie', 3),
  ('Cockatiel', 3),
  ('Parrot', 3),
  ('Canary', 3),
  ('Lop', 4),
  ('Holland Lop', 4),
  ('Angora', 4),
  ('Syrian', 5),
  ('Roborovski', 5),
  ('Cavies', 6),
  ('Mixed', 7),
  ('Python', 8),
  ('Lizard', 8),
  ('Turtle', 8)
ON CONFLICT (name, species_id) DO NOTHING;

-- 7. Create epidemiological_alerts table if it doesn't exist
CREATE TABLE IF NOT EXISTS epidemiological_alerts (
  id SERIAL PRIMARY KEY,
  disease TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  radius_km DECIMAL(8, 2) NOT NULL,
  severity_level TEXT DEFAULT 'medium',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Enable RLS on tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE breeds ENABLE ROW LEVEL SECURITY;
ALTER TABLE species ENABLE ROW LEVEL SECURITY;

-- 9. RLS Policies for users table
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

-- 10. RLS Policies for pets table
CREATE POLICY "Clients can view own pets" ON pets
  FOR SELECT USING (client_id = auth.uid());

CREATE POLICY "Clients can insert own pets" ON pets
  FOR INSERT WITH CHECK (client_id = auth.uid());

CREATE POLICY "Clients can update own pets" ON pets
  FOR UPDATE USING (client_id = auth.uid());

-- 11. RLS Policies for species (public read)
CREATE POLICY "Anyone can view species" ON species
  FOR SELECT USING (true);

-- 12. RLS Policies for breeds (public read)
CREATE POLICY "Anyone can view breeds" ON breeds
  FOR SELECT USING (true);

-- Verify schema
SELECT 'Schema setup complete!' as status;
