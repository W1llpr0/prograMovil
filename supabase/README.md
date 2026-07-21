# Backend Supabase de VetCare

VetCare usa Supabase como backend completo. Flutter se conecta directamente a:

- Supabase Auth para registro, inicio de sesión y JWT.
- PostgreSQL para perfiles, mascotas, citas e historia clínica.
- Database Functions (RPC) para operaciones que deben ser atómicas.
- Row Level Security (RLS) para separar los datos de clientes y veterinarios.
- Supabase Storage para fotos y documentos clínicos o legales.

No se necesita una API REST propia ni un servidor adicional.

## Despliegue

### Con Supabase CLI

Desde la raíz del repositorio:

```bash
supabase login
supabase link --project-ref TU_PROJECT_REF
supabase db push
```

Las migraciones se ejecutan en orden cronológico. La migración
`20260520000000_vetcare_baseline.sql` permite iniciar un proyecto vacío; las
migraciones siguientes conservan compatibilidad con instalaciones anteriores y
`20260720000000_complete_workflows.sql` instala las operaciones completas.

### Desde el SQL Editor

En un proyecto vacío, ejecuta los archivos de `supabase/migrations` en orden
alfabético. No uses `supabase_complete_schema.sql`: se conserva únicamente como
referencia histórica y no contiene el contrato actual.

Después del despliegue, en **Project Settings > API**, copia la URL y la clave
publicable (anon/publishable) y ejecuta Flutter así:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://TU_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_CLAVE_PUBLICABLE
```

La clave `service_role` nunca debe incorporarse en Flutter ni versionarse.

## Configuración de Auth en el panel

En **Authentication > Providers > Email**:

- habilita Email/Password;
- mantén activa la confirmación de correo para producción;
- configura la URL de la aplicación y los redirect URLs de Android/iOS;
- aplica límites de solicitudes y CAPTCHA si el proyecto estará expuesto;
- no reveles desde la interfaz si un correo está registrado.

VetCare devuelve `INVALID_CREDENTIALS` con el mismo texto para correo inexistente,
contraseña incorrecta o formato inválido. Los errores internos de Supabase y
PostgreSQL se conservan fuera de las respuestas visibles al usuario.

## Tablas y relaciones

| Tabla | Propósito | Relación principal |
|---|---|---|
| `users` | Perfil compartido y rol | `id -> auth.users.id` |
| `clients` | Datos geográficos del cliente | `user_id -> users.id` |
| `veterinarians` | Colegiatura, experiencia y estado | `user_id -> users.id` |
| `specialties` | Catálogo de especialidades | catálogo |
| `veterinarian_specialties` | Especialidades atendidas | veterinario + especialidad |
| `veterinarian_availability` | Horario semanal | veterinario |
| `species`, `breeds` | Catálogo animal | raza -> especie |
| `pets` | Pacientes | mascota -> cliente y raza |
| `consultations` | Cita e historia clínica | mascota + veterinario + especialidad |
| `consultation_documents` | Resultados clínicos | documento -> consulta |
| `medication_schedules` | Receta y próximas tomas | medicamento -> consulta |
| `treatment_adherence` | Confirmación de una toma | registro -> medicamento |
| `epidemiological_alerts` | Brotes geolocalizados | alerta -> consulta |
| `morphological_records` | Seguimiento de especies exóticas | registro -> mascota |
| `legal_documents` | Bóveda CITES/facturas | documento -> mascota |
| `reviews` | Calificación posterior | reseña -> consulta, cliente y veterinario |

El trigger sobre `auth.users` crea automáticamente el perfil y la fila de
`clients` o `veterinarians` usando los metadatos enviados durante el registro.

## Contrato de respuestas RPC

Todas las operaciones mutables devuelven el mismo sobre JSON:

```json
{
  "success": true,
  "code": "CODIGO_ESTABLE",
  "message": "Mensaje legible",
  "data": {}
}
```

Los errores de negocio también se devuelven como JSON con `success: false` y un
`code` estable. Flutter los traduce mediante `GenericResponse.fromRpc`.

### `book_consultation`

Agenda una cita y comprueba dueño, veterinario, especialidad, disponibilidad y
colisión de horario.

| Input | Tipo | Obligatorio |
|---|---|---|
| `p_pet_id` | `bigint` | sí |
| `p_veterinarian_id` | `uuid` | sí |
| `p_specialty_id` | `bigint` | no |
| `p_scheduled_at` | `timestamptz` | sí |
| `p_reason` | `text` | no |

Éxito: `CONSULTATION_BOOKED`. Errores esperados: `UNAUTHENTICATED`,
`PET_FORBIDDEN`, `INVALID_DATE`, `VET_NOT_FOUND`, `SPECIALTY_MISMATCH`,
`OUTSIDE_AVAILABILITY` y `SLOT_TAKEN`.

### `start_consultation`

Input: `p_consultation_id bigint`. Solo el veterinario asignado puede iniciar la
atención. Éxito: `CONSULTATION_STARTED`. Errores: `CONSULTATION_FORBIDDEN` o
`INVALID_STATUS`.

### `complete_consultation`

Finaliza atómicamente la atención, registra signos vitales, crea la receta,
genera la alerta epidemiológica cuando corresponde y calcula el SHA-256.

| Input | Tipo | Obligatorio |
|---|---|---|
| `p_consultation_id` | `bigint` | sí |
| `p_diagnosis` | `text` | sí |
| `p_treatment` | `text` | sí |
| `p_notes` | `text` | no |
| `p_is_contagious` | `boolean` | no (`false`) |
| `p_vitals` | `jsonb` | no (`{}`) |
| `p_medications` | `jsonb[]` | no (`[]`) |

Ejemplo de `p_vitals`:

```json
{"weight_kg": 12.5, "temperature_c": 38.4, "heart_rate_bpm": 96}
```

Ejemplo de un elemento de `p_medications`:

```json
{
  "name": "Amoxicilina",
  "dosage": "250 mg",
  "frequency": "Cada 8 horas",
  "frequency_hours": 8,
  "start_date": "2026-07-20",
  "end_date": "2026-07-27",
  "next_dose_at": "2026-07-20T21:00:00-05:00"
}
```

Éxito: `CONSULTATION_COMPLETED`; `data.integrity_hash` contiene el hash. Errores:
`VALIDATION_ERROR`, `INVALID_MEDICATIONS`, `CONSULTATION_FORBIDDEN` o
`INVALID_STATUS`.

### `submit_review`

Inputs: `p_consultation_id bigint`, `p_rating integer` (1-5) y
`p_comment text`. Solo el cliente dueño puede calificar una consulta completada
y existe una sola reseña por consulta. Éxito: `REVIEW_SAVED`.

### `available_slots`

Inputs: `p_veterinarian_id uuid` y `p_date date`. Devuelve filas con
`slot_at timestamptz`, usando la duración configurada en la disponibilidad del
veterinario y omitiendo horarios ya reservados.

## Storage

| Bucket | Uso | Visibilidad |
|---|---|---|
| `profiles` | Fotos de perfil | público |
| `pet-images` | Fotos de mascotas | público |
| `consultation-docs` | Radiografías, análisis y resultados | privado |
| `legal-docs` | CITES y comprobantes | privado |

Las políticas usan carpetas cuyo primer segmento es el UUID del usuario. Los
documentos privados se leen mediante sesión autenticada o URL firmada.

## Verificación local del SQL

Los archivos en `supabase/tests` permiten comprobar el esquema en PostgreSQL 15:

1. aplicar `postgres_bootstrap.sql`;
2. aplicar todas las migraciones en orden;
3. aplicar `workflow_smoke.sql`.

La prueba cubre registro de perfiles, mascota, agendamiento, inicio y cierre de
consulta, medicación, alerta, hash y reseña.
