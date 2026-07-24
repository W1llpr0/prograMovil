# Guia de pruebas de VetCare

## 1. Cuentas demo

Todas las cuentas usan la contrasena local configurada en
`VETCARE_DEMO_PASSWORD`. El valor real no se guarda en Git.

| Rol | Correo | Datos principales |
|---|---|---|
| Cliente | `ana.cliente.vetcare@example.com` | Luna y Michi |
| Cliente | `carlos.cliente.vetcare@example.com` | Rocky y Nala |
| Cliente | `lucia.cliente.vetcare@example.com` | Coco y Kiara |
| Veterinaria | `valeria.vet.vetcare@example.com` | Medicina General, Dermatologia y Cardiologia |
| Veterinario | `rodrigo.vet.vetcare@example.com` | Medicina General, Cirugia y Animales Exoticos |

Antes de ejecutar el seed, agrega una contrasena de al menos 12 caracteres a
`.env.local` (este archivo esta ignorado por Git):

```properties
VETCARE_DEMO_PASSWORD=REEMPLAZAR_CON_UNA_CONTRASENA_SEGURA
```

El seed puede ejecutarse nuevamente sin duplicar estas cinco cuentas:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File supabase\seed_demo_data.ps1
```

Solo se eliminan y recrean las cinco cuentas listadas arriba. Las cuentas reales
del proyecto no se modifican.

## 2. Configurar SMTP

El proveedor de correo incorporado de Supabase solo permite unos pocos correos
por hora y no es adecuado para registrar muchos usuarios. Para habilitar el
registro real:

1. Crea una cuenta en un proveedor SMTP, por ejemplo Resend, Postmark, SendGrid,
   Amazon SES o Mailtrap para pruebas.
2. Verifica el dominio o correo remitente en el proveedor.
3. Copia `supabase/.env.smtp.example` como
   `supabase/.env.smtp.local`.
4. Completa host, puerto, usuario, API key o contrasena y remitente.
5. Ejecuta:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File supabase\configure_smtp.ps1
```

El archivo `.env.smtp.local` esta ignorado por Git y nunca debe compartirse ni
confirmarse en el repositorio. La confirmacion de correo permanece activada.

Para pruebas con correos ficticios y sin SMTP, ejecuta:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File supabase\configure_auth_testing.ps1
```

En este modo no se envia un correo ni se muestra la pantalla de confirmacion:
Supabase confirma la cuenta automaticamente. No debe utilizarse en produccion.

## 3. Casos de uso

### CU-01: registrar un cliente

Requisito: SMTP configurado o modo de pruebas sin SMTP activado.

1. Abre **Registrate**.
2. Selecciona **Dueno**.
3. Usa un correo real y unico con SMTP, o uno ficticio y unico en modo de pruebas.
4. Completa nombres, documento, telefono y una contrasena segura.
5. Pulsa **Completar registro**.
6. Con SMTP, confirma el correo recibido. En modo de pruebas, inicia sesion
   directamente.

Resultado esperado: aparecen filas relacionadas en `auth.users`,
`public.users` y `public.clients`. La aplicacion no inicia sesion antes de la
confirmacion.

### CU-02: seguridad del login

1. Escribe un correo inexistente y cualquier contrasena.
2. Repite con una cuenta existente y una contrasena incorrecta.

Resultado esperado en ambos casos: **Correo o contrasena incorrectos**. La
pantalla no revela si un correo existe.

### CU-03: panel y mascotas del cliente

1. Inicia sesion con Ana.
2. Comprueba que el panel muestre consultas y las mascotas Luna y Michi.
3. Abre **Mascotas** y entra al expediente de Luna.
4. Revisa consultas pendientes y completadas.

Resultado esperado: la informacion coincide con `pets` y `consultations`, y
Ana no puede ver mascotas de Carlos o Lucia.

### CU-04: crear y editar mascota

1. Pulsa **Anadir**.
2. Completa nombre, especie, sexo, fecha, peso y raza.
3. Guarda la mascota.
4. Desde el expediente modifica peso o alergias.

Resultado esperado: la fila se crea o actualiza en `pets` con el `client_id`
del usuario autenticado.

### CU-05: agendar una cita

1. Pulsa **Agendar cita**.
2. Selecciona una mascota y Medicina General.
3. Pulsa **Continuar**.
4. Selecciona veterinario, fecha, horario y escribe el motivo.
5. Confirma.

Resultado esperado: `available_slots` solo muestra horarios de disponibilidad;
`book_consultation` crea una fila en `consultations` y rechaza horarios
duplicados.

### CU-06: adherencia a medicamentos

1. Entra en **Medicamentos** desde el panel del cliente.
2. Cambia entre las mascotas y confirma que el sombreado y el tratamiento
   pertenecen a la misma mascota.
3. Revisa medicamento, dosis, frecuencia y la hora de la proxima dosis.
4. Cuando corresponda, pulsa **Marcar dosis** dos veces rapidamente.

Resultado esperado: se agrega una fila a `treatment_adherence` relacionada con
`medication_schedules`, la proxima dosis avanza y el doble toque no crea una
segunda fila. Si aun no corresponde, el boton muestra **Aun no**.

### CU-07: perfil, configuracion y resenas

1. Abre **Perfil** y modifica un dato personal.
2. Abre **Configuracion** y cambia idioma o apariencia.
3. Abre una consulta completada y pulsa **Evaluar atencion**.
4. Selecciona estrellas y envia una resena.
5. Abre **Mis resenas** y comprueba mascota, especialidad, fecha y diagnostico.

Resultado esperado: el perfil se actualiza sin permitir cambiar el rol; la
resena se crea una sola vez en `reviews` y deja de mostrarse el boton para esa
consulta. Idioma y apariencia se guardan en `user_preferences`, se conservan al
cerrar la app y se sincronizan al iniciar la misma cuenta en otro dispositivo.

### CU-08: panel veterinario

1. Cierra sesion e ingresa con Valeria o Rodrigo.
2. Revisa total de citas, pendientes y paciente en sala.
3. Abre las pestanas **Agenda** y **Pacientes**.
4. Toca una tarjeta de **Pacientes**.

Resultado esperado: solo aparecen consultas asignadas al veterinario y sus
pacientes autorizados. **Atendidas hoy** cuenta las consultas finalizadas hoy
segun `completed_at`, aunque se hayan programado para otra fecha. **Proximas
pendientes** incluye citas pendientes, programadas o confirmadas de hoy y fechas
posteriores. Cada tarjeta muestra cuantas consultas fueron atendidas y cuantas
estan pendientes; al tocarla abre la siguiente accion disponible.

### CU-09: iniciar consulta

1. En **Agenda**, abre una cita pendiente.
2. Revisa paciente, peso, alergias y motivo.
3. Pulsa **Iniciar consulta**.

Resultado esperado: `start_consultation` cambia el estado a `in_progress` y
registra `started_at`. Un cliente no puede ejecutar esta operacion.

### CU-10: registrar y finalizar consulta

1. Escribe diagnostico, tratamiento, notas y signos vitales.
2. Pulsa **Borrador** y verifica que el formulario permanezca abierto.
3. Pulsa **Adjuntar**.
4. Opcionalmente selecciona un PDF, JPG o PNG menor a 10 MB.
5. Pulsa **Guardar y finalizar cita**.

Resultado esperado: el borrador queda en `consultations`; los archivos usan el
bucket `consultation-docs`; al finalizar se guarda `completed_at`, medicamentos
y la firma de integridad SHA-256. Al volver a **Pacientes**, aumenta el contador
de atendidas y disminuye el de pendientes. Un veterinario nunca debe ver
**Evaluar atencion**.

### CU-11: alerta epidemiologica

1. Durante una consulta veterinaria activa **Diagnostico contagioso**.
2. Finaliza la consulta.
3. Entra con un cliente y abre **Alertas epidemiologicas**.

Resultado esperado: se crea una fila en `epidemiological_alerts`. Los datos de
la alerta aparecen aunque el mapa base requiere adicionalmente una
`GOOGLE_MAPS_KEY` valida.

Para habilitar el mapa base en Android, agrega en
`app/android/local.properties`:

```properties
GOOGLE_MAPS_KEY=tu_clave_android_restringida
```

Luego compila con:

```powershell
flutter build apk --release --dart-define=GOOGLE_MAPS_ENABLED=true
```

### CU-12: aislamiento entre usuarios

1. Inicia sesion como Ana y anota una mascota propia.
2. Cierra sesion e ingresa como Carlos.
3. Comprueba que la mascota de Ana no aparece.
4. Repite con un veterinario que no tenga una consulta asignada.

Resultado esperado: las politicas RLS impiden leer o modificar mascotas,
consultas, documentos y adherencias ajenas.

## 4. Comprobacion rapida en Supabase

Ejecuta en el SQL Editor:

```sql
select role, count(*) from public.users group by role order by role;
select status, count(*) from public.consultations group by status order by status;
select count(*) as mascotas from public.pets;
select count(*) as resenas from public.reviews;
select count(*) as medicamentos from public.medication_schedules;
select count(*) as adherencias from public.treatment_adherence;
select count(*) as alertas from public.epidemiological_alerts;
```

Valores iniciales esperados despues del seed: al menos 5 usuarios demo, 6
mascotas demo, 12 consultas demo, 4 resenas y 4 tratamientos.
