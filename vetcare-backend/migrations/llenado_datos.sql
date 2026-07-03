-- Insertar Sexos Base
INSERT INTO sex (name) VALUES ('Macho'), ('Hembra'), ('Desconocido');

-- Insertar Especies y Razas
INSERT INTO species (name, is_exotic) VALUES 
('Canino', false), 
('Felino', false), 
('Reptil', true);

INSERT INTO breed (species_id, name, description) VALUES 
(1, 'Bulldog Francés', 'Perro de compañía'),
(2, 'Persa', 'Gato de pelo largo'),
(3, 'Iguana Verde', 'Reptil arbóreo');

-- Insertar Usuarios (Se respeta el ENUM 'client' y 'vet')
INSERT INTO "user" (id, sex_id, role, email, first_name, last_name, phone) VALUES 
('11111111-1111-1111-1111-111111111111', 1, 'client', 'carlos@ejemplo.com', 'Carlos', 'Gómez', '999888777'),
('22222222-2222-2222-2222-222222222222', 2, 'vet', 'dra.ana@vetcare.com', 'Ana', 'Martínez', '999111222');

INSERT INTO client (user_id, address, identity_document) VALUES 
('11111111-1111-1111-1111-111111111111', 'Av. Javier Prado Este, Santiago de Surco, Lima', '70000001');

INSERT INTO veterinarian (user_id, license_number, years_experience) VALUES 
('22222222-2222-2222-2222-222222222222', 'CMVP-12345', 8);

INSERT INTO pet (client_id, breed_id, sex_id, name, birth_date, current_weight) VALUES 
(1, 1, 1, 'Buster', '2023-01-15', 12.5);

-- Insertar Consulta (Se respeta el ENUM 'Programada')
INSERT INTO consultation (pet_id, veterinarian_id, status, consultation_datetime, reason) VALUES 
(1, 1, 'Programada', '2026-07-10 15:00:00+00', 'Chequeo general y vacunación');