-- Migration: 20260521200000_fix_pets_fk_and_more_breeds
-- Fix: pets.client_id FK was pointing to a non-existent "clients" table.
--      Change it to reference auth.users directly.
-- Also: add many more species and breeds.

-- ─── 1. Fix the FK constraint ─────────────────────────────────────────────
ALTER TABLE public.pets DROP CONSTRAINT IF EXISTS pets_client_id_fkey;
ALTER TABLE public.pets
  ADD CONSTRAINT pets_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- ─── 2. Add more species ───────────────────────────────────────────────────
INSERT INTO public.species (name, is_exotic) VALUES
  ('Tortuga',    true),
  ('Loro',       false),
  ('Serpiente',  true),
  ('Chinchilla', false),
  ('Hurón',      false),
  ('Iguana',     true),
  ('Pato',       false),
  ('Canario',    false),
  ('Ratón',      false),
  ('Erizo',      true)
ON CONFLICT (name) DO NOTHING;

-- ─── 3. Many more breeds for Perro ────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Labrador Retriever'),('Golden Retriever'),('Pastor Alemán'),
  ('Bulldog Francés'),('Bulldog Inglés'),('Poodle Toy'),('Poodle Mediano'),('Poodle Grande'),
  ('Beagle'),('Yorkshire Terrier'),('Chihuahua'),('Shih Tzu'),
  ('Husky Siberiano'),('Rottweiler'),('Boxer'),('Dachshund'),
  ('Cocker Spaniel Americano'),('Cocker Spaniel Inglés'),('Border Collie'),
  ('Australian Shepherd'),('Dobermann'),('Pomerania'),('Maltés'),
  ('Bichón Frisé'),('Schnauzer Miniatura'),('Schnauzer Estándar'),('Gran Danés'),
  ('Akita Inu'),('Shar Pei'),('Samoyedo'),('Malamute de Alaska'),
  ('Bernés de la Montaña'),('Weimaraner'),('Vizsla'),('Setter Irlandés'),
  ('Basset Hound'),('Bloodhound'),('Dálmata'),('Chow Chow'),
  ('Shiba Inu'),('Pug'),('Lhasa Apso'),('Bullmastiff'),('Mastín Napolitano'),
  ('Jack Russell Terrier'),('Bull Terrier'),('Fox Terrier'),
  ('Cairn Terrier'),('West Highland White Terrier'),('Scottish Terrier'),
  ('Cavalier King Charles Spaniel'),('Springer Spaniel'),
  ('Pointer'),('Setter Inglés'),('Braco Alemán'),
  ('Galgo'),('Lebrél Afgano'),('Whippet'),('Greyhound'),
  ('Cheasapeake Bay Retriever'),('Flat-Coated Retriever'),('Nova Scotia Duck Tolling Retriever'),
  ('Bernedoodle'),('Goldendoodle'),('Labradoodle'),('Cockapoo'),
  ('Mestizo / Sin raza definida')
) AS t(breed_name)
WHERE s.name = 'Perro'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 4. Many more breeds for Gato ─────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Persa'),('Siamés'),('Maine Coon'),('Ragdoll'),('Bengalí'),
  ('Abisinio'),('Sphynx'),('British Shorthair'),('Scottish Fold'),('Birmano'),
  ('Ruso Azul'),('Noruego del Bosque'),('Angora Turco'),('Devon Rex'),
  ('Cornish Rex'),('Burmés'),('Tonkinés'),('Somali'),('Manx'),
  ('Savannah'),('Chausie'),('Ocicat'),('Singapura'),('Balinés'),
  ('Javanés'),('Turco Van'),('Chartreux'),('Korat'),('Bombay'),
  ('Munchkin'),('Scottish Straight'),('Peterbald'),('Selkirk Rex'),
  ('American Curl'),('LaPerm'),('Pixie-Bob'),('Ragamuffin'),
  ('Himalayo'),('Exótico de Pelo Corto'),
  ('Común Europeo / Mestizo')
) AS t(breed_name)
WHERE s.name = 'Gato'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 5. Breeds for Tortuga ────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Tortuga Mediterránea (Testudo hermanni)'),
  ('Tortuga de Horsfield (Testudo horsfieldii)'),
  ('Tortuga Griega (Testudo graeca)'),
  ('Tortuga de Orejas Rojas (Trachemys scripta elegans)'),
  ('Tortuga de Florida (Pseudemys floridana)'),
  ('Tortuga de Caja (Terrapene carolina)'),
  ('Tortuga Mapa (Graptemys geographica)'),
  ('Tortuga Sulcata (Centrochelys sulcata)'),
  ('Tortuga Leopardo (Stigmochelys pardalis)'),
  ('Tortuga India Estrellada (Geochelone elegans)'),
  ('Tortuga Rusa (Testudo horsfieldii)'),
  ('Tortuga Pintada (Chrysemys picta)'),
  ('Tortuga de Agua Dulce Europea (Emys orbicularis)'),
  ('Tortuga Ibérica (Mauremys leprosa)'),
  ('Tortuga Matamata (Chelus fimbriata)'),
  ('Otra especie / Mestiza')
) AS t(breed_name)
WHERE s.name = 'Tortuga'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 6. Breeds for Loro ───────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Loro Gris Africano'),('Guacamayo Azul y Amarillo'),('Guacamayo Escarlata'),
  ('Guacamayo Verde'),('Amazona Frentiazul'),('Amazona Frente Roja'),
  ('Cotorra Argentina'),('Periquito Australiano'),('Cockatiel / Ninfa'),
  ('Cacatúa Blanca'),('Cacatúa de Cresta Amarilla'),('Cacatúa Rosada'),
  ('Lori Arcoíris'),('Agapornis / Inseparable'),('Eclecto'),
  ('Conuro Sol'),('Conuro Alas de Canela'),('Loro Pionus'),
  ('Loro Senegalés'),('Loro de Pecho Naranja'),
  ('Otra especie de loro')
) AS t(breed_name)
WHERE s.name = 'Loro'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 7. Breeds for Serpiente ──────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Ball Python / Pitón Real'),('Boa Constrictor'),('Pitón Reticulada'),
  ('Pitón de Alfombra'),('Serpiente del Maíz'),('Serpiente Real de California'),
  ('Serpiente Real Hondureña'),('Serpiente Rey Escarlata'),
  ('Serpiente del Trigo'),('Serpiente Ratonera'),
  ('Serpiente Nariz de Cerdo'),('Hognose Occidental'),
  ('Kingsnake'),('Milk Snake'),
  ('Otra especie de serpiente')
) AS t(breed_name)
WHERE s.name = 'Serpiente'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 8. Breeds for Iguana ─────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Iguana Verde (Iguana iguana)'),('Iguana Azul (Cyclura lewisi)'),
  ('Iguana de Roca Negra'),('Iguana del Desierto'),
  ('Iguana Rinoceronte'),('Dragón de Agua Chino'),
  ('Dragón de Agua Australiano'),('Camaleón Velado'),
  ('Camaleón de Jackson'),('Otro lagarto / iguana')
) AS t(breed_name)
WHERE s.name = 'Iguana'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 9. Breeds for Conejo ─────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Holland Lop'),('Mini Lop'),('French Lop'),('English Lop'),
  ('Lionhead'),('Rex'),('Mini Rex'),('Angora Inglés'),('Angora Francés'),
  ('Angora Gigante'),('Belier Francés'),('Belier Inglés'),
  ('New Zealand'),('Californiano'),('Harlequin'),
  ('Dutch / Holandés'),('Flemish Giant / Gigante de Flandes'),
  ('Netherlandse Dwarf'),('Polish'),('Silver Marten'),
  ('Conejo de Monte / Sin raza definida')
) AS t(breed_name)
WHERE s.name = 'Conejo'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 10. Breeds for Chinchilla ────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Chinchilla de Cola Corta (Chinchilla brevicaudata)'),
  ('Chinchilla de Cola Larga (Chinchilla lanigera)'),
  ('Beige'),('Blanca'),('Mosaico'),('Violeta'),('Zafiro'),
  ('Carbón / Charcoal'),('Ébano'),('Pastilla / TOV'),
  ('Estándar / Gris')
) AS t(breed_name)
WHERE s.name = 'Chinchilla'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 11. Breeds for Ave ───────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Canario'),('Periquito Australiano'),('Pinzón Cebra'),
  ('Diamante de Gould'),('Diamante Mandarín'),('Jilguero'),
  ('Cardenal Rojo'),('Pardillo'),('Bengalí'),
  ('Estornino Pío'),('Mirlo'),('Zorzal'),
  ('Paloma Doméstica'),('Paloma Mensajera'),
  ('Cotorra Monje'),('Ninfas / Cockatiel'),
  ('Otra especie de ave')
) AS t(breed_name)
WHERE s.name = 'Ave'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 12. Breeds for Hámster ───────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Hámster Sirio / Dorado'),('Hámster Ruso Enano'),
  ('Hámster Campbell'),('Hámster Chino'),('Hámster Roborowski'),
  ('Hámster de Eunguroo'),('Otro hámster')
) AS t(breed_name)
WHERE s.name = 'Hámster'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 13. Breeds for Hurón ─────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Hurón Estándar'),('Hurón Angora'),
  ('Sable'),('Chocolate'),('Albino'),('Silver Mitt'),
  ('Panda'),('Blaze'),('Roan'),('Cinnamon'),('Champagne'),
  ('Otro hurón')
) AS t(breed_name)
WHERE s.name = 'Hurón'
ON CONFLICT (name, species_id) DO NOTHING;

-- ─── 14. Breeds for Cobayo ────────────────────────────────────────────────
INSERT INTO public.breeds (name, species_id)
SELECT t.breed_name, s.id
FROM public.species s,
(VALUES
  ('Americano'),('Abisinio'),('Peruvian'),('Silkie / Sheltie'),
  ('Texel'),('Teddy'),('Rex'),('Coronet'),('White Crested'),
  ('Otro cobayo / cuy')
) AS t(breed_name)
WHERE s.name = 'Cobayo'
ON CONFLICT (name, species_id) DO NOTHING;
