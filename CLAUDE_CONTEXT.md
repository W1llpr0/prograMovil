# Claude Context - PrograMovil

## Project Summary
- Proyecto Flutter/Dart para una app veterinaria llamada VetCare.
- El codigo principal vive en `app/` dentro de este repo.
- Backend: Supabase (Auth, PostgreSQL, RLS, Storage).
- State management: GetX.

## Branch And Working Rule
- Rama actual: `Matias`.
- No trabajar sobre `main` a menos que el usuario lo pida explicitamente.

## Current Focus
- Flujo de agendamiento de citas redisenado.
- Orden actual del flujo: seleccionar veterinario -> seleccionar fecha y hora -> seleccionar mascota al confirmar.
- La pantalla de agendar cita ya no debe pedir la mascota al inicio.

## Recent Important Fixes
- Se soluciono el error de "no hay veterinarios disponibles" con politicas RLS en Supabase.
- Se agrego la columna `years_experience` a `veterinarians`.
- Se corrigio un cast de `List<dynamic>` a `List<int>` en la carga de citas.
- Se redisenio la pantalla de booking para usar `GetView<BookAppointmentController>`.
- Se corrigio el error de `BookAppointmentController not found` usando binding de GetX.
- Se agregaron claves de traduccion nuevas para el flujo de citas.

## Key Files
- `app/lib/main.dart` - rutas y bindings de GetX.
- `app/lib/pages/book_appointment/book_appointment_page.dart` - UI del flujo de agendamiento.
- `app/lib/pages/book_appointment/book_appointment_controller.dart` - logica del flujo de agendamiento.
- `app/lib/pages/home/home_page.dart` - tab de citas y CTA para agendar.
- `app/lib/pages/home/home_controller.dart` - carga de citas proximas.
- `app/lib/configs/app_translations.dart` - textos traducidos.

## Booking Flow Details
- Step 0: listar veterinarios disponibles y seleccionar uno.
- Step 1: elegir fecha, hora y motivo.
- Step 2: elegir mascota y confirmar.
- El boton principal cambia segun el paso: siguiente o confirmar.

## Supabase Notes
- Los veterinarios deben ser visibles para clientes.
- Los nombres de usuario se obtienen mediante join con `users`.
- La disponibilidad de veterinarios tambien debe ser visible para usuarios autenticados.

## UI Notes
- Si aparece texto como `book_new_appt`, significa que faltan traducciones cargadas o que la app necesita reinicio completo.
- Para cambios de rutas, bindings o traducciones, preferir hot restart completo, no solo hot reload.

## Useful Commands
- Ejecutar app Flutter: `cd /Users/matiasalarcon/PrograMovilTrabajo/prograMovil/app && flutter run -d emulator-5554`
- Revisar rama actual: `git -C /Users/matiasalarcon/PrograMovilTrabajo/prograMovil branch --show-current`

## Notes For Future Work
- Mantener cambios pequenos y enfocados.
- No revertir cambios ajenos sin pedir confirmacion.
- Si una pantalla usa GetX, preferir `GetView<T>` + binding en ruta antes que `Get.find()` dentro de `build`.