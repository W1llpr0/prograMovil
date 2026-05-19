# 📱 Programacion Movil
Proyecto del curso de Programación Móvil de la Universidad de Lima.

## Índice

Pulsa cualquiera de los subtítulos para ir directamente a la sección:

1. [Integrantes](#integrantes)
2. [Enunciado del Programa](#enunciado-del-programa-aplicación-móvil-veterinaria)
3. [Explicación del entorno de desarrollo](#explicación-del-entorno-de-desarrollo-requisitos-previos)
4. [Requerimientos](#requerimientos)
5. [Diagrama de Despliegue](#diagrama-de-despliegue)
6. [Casos de Uso](#casos-de-uso)
7. [Descripción de Casos de Uso](#descripción-de-casos-de-uso)
8. [Diagrama de Base de Datos](#diagrama-de-base-de-datos-schema)
9. [Diagrama de Clases](#diagrama-de-clases)
10. [Mockups](#mockups-prototipos-de-interfaz)


## 👥 Integrantes
- Juan Zavalaga
- Franco Melchor  
- Matias  Alarcon
- Nicolas Champa  

## 📝 Enunciado del Programa (Aplicación Móvil Veterinaria)

Una clínica veterinaria requiere el desarrollo de una aplicación móvil para la gestión de sus servicios de salud animal y el historial médico de sus pacientes. El sistema debe centralizar la información de todos sus usuarios (clientes -dueño de la mascota- y veterinarios), quienes deben registrar sus nombres, apellidos, correo electrónico, contraseña, teléfono de contacto, una foto de perfil y su sexo.

Existen dos tipos de perfiles de usuario:
- Clientes: Son los dueños de las mascotas, de quienes se debe registrar además su dirección y documento de identidad.
- Veterinarios: Profesionales de la clínica de los cuales se requiere el número de colegiatura y sus años de experiencia.

Para facilitar el seguimiento de sus animales, los clientes pueden registrar múltiples mascotas, identificando para cada una su nombre, fecha de nacimiento, sexo, peso actual y una fotografía. Cada mascota pertenece a una raza específica, la cual está asociada a una especie (como canino, felino o exótico). El registro de la raza incluye su nombre, una descripción y una imagen referencial.

A través de la app, los clientes pueden agendar consultas médicas para sus mascotas seleccionando a un veterinario. Al agendar, el cliente elige uno de los horarios disponibles definidos por intervalos en la agenda del veterinario, junto con el motivo de la visita, creando la consulta con un estado inicial (por ejemplo: pendiente). Durante la atención, el veterinario actualiza el estado y registra el diagnóstico, tratamiento recetado y documentos adjuntos.

Además, las atenciones pueden clasificarse en múltiples especialidades o servicios (como medicina general, dermatología, traumatología o peluquería), de las cuales se registra su nombre, descripción y un ícono representativo. Finalmente, para medir la calidad del servicio, los clientes pueden calificar (1, 2, 3, 4 o 5) y dejar reseñas sobre las consultas que han finalizado (completadas), indicando su opinión detallada y la fecha y hora en que publicaron su comentario.

## Explicación del entorno de desarrollo (Requisitos Previos)

Para la construcción de este proyecto, se ha seleccionado un stack tecnológico orientado a una arquitectura **Serverless / BaaS (Backend-as-a-Service)**. Flutter se comunica directamente con Supabase, eliminando la necesidad de una API REST intermedia. A continuación, se detallan las herramientas utilizadas, su propósito y el proceso de configuración necesario.

### Stack Tecnológico

| Capa | Tecnología | Propósito |
|------|-----------|----------|
| **Front-end / Móvil** | Flutter + Dart | App compilada nativamente para Android e iOS |
| **Autenticación** | Supabase Auth (JWT) | Registro, login y autorización por roles mediante JWT |
| **Base de Datos** | Supabase PostgreSQL | Base de datos relacional gestionada en la nube |
| **Almacenamiento de Archivos** | Supabase Storage | Imágenes, documentos médicos y archivos CITES |
| **Lógica de Negocio Serverless** | Supabase Edge Functions + Database Triggers | Generación de cronogramas, hashes de autenticidad y alertas epidemiológicas |

### 1. Flutter y Dart (Front-end)
* **Descripción:** Flutter es el SDK de Google para crear aplicaciones compiladas nativamente para móvil desde una única base de código. Utiliza **Dart**, un lenguaje optimizado para interfaces de usuario rápidas y reactivas.
* **Instalación:**
    1.  Descarga el SDK de Flutter desde [flutter.dev](https://docs.flutter.dev/get-started/install) según tu sistema operativo.
    2.  Extrae el archivo en una ruta sin espacios (ej: `C:\src\flutter`).
    3.  Agrega la carpeta `bin` de Flutter a las variables de entorno de tu sistema (**PATH**).
    4.  Ejecuta `flutter doctor` en la terminal para verificar dependencias de Android/iOS pendientes.

### 2. Supabase (BaaS)
* **Descripción:** Plataforma open-source de Backend-as-a-Service que provee autenticación JWT, base de datos PostgreSQL, almacenamiento de archivos y funciones serverless (Edge Functions + Triggers). Reemplaza completamente la API REST intermedia.
* **Configuración:**
    1.  Crea un proyecto en [supabase.com](https://supabase.com).
    2.  Copia las variables `SUPABASE_URL` y `SUPABASE_ANON_KEY` desde el panel del proyecto.
    3.  Agrega el paquete en Flutter: `flutter pub add supabase_flutter`.
    4.  Inicializa el cliente en `main.dart`: `await Supabase.initialize(url: ..., anonKey: ...)`.

### 3. Visual Studio Code (IDE)
* **Descripción:** Editor de código fuente versátil que sirve como estación de trabajo principal para el desarrollo de todas las capas de la aplicación.
* **Configuración:**
    1.  Descarga e instala [VS Code](https://code.visualstudio.com/).
    2.  Instala la extensión oficial de **Flutter** (esto instalará automáticamente Dart).
    3.  Instala la extensión **Supabase** para autocompletado de SQL y gestión del proyecto.

### 4. Android Studio
* Para mayor comodidad en el entorno de desarrollo móvil (Front-end) y no depender de extensiones en VS Code, instalar Android Studio es la mejor opción (incluyendo SDKs de Android).

## Requerimientos

### 1. Requerimientos Funcionales:
Lo que el sistema debe hacer (acciones y funcionalidades específicas)

* Gestión de Usuarios y Autenticación:
    * **RF01:** El sistema debe permitir el registro de nuevos usuarios asignándoles un rol específico (Cliente o Veterinario).
    * **RF02:** El sistema debe permitir a los usuarios iniciar sesión utilizando su correo electrónico y contraseña.
    * **RF03:** El sistema debe permitir a los usuarios (clientes y veterinarios) editar la información de su perfil (teléfono, foto de perfil, et*) según los campos permitidos para su ro*

* Gestión de Mascotas y Catálogo:
    * **RF04:** El sistema debe permitir a los clientes registrar, editar y visualizar el perfil de sus mascotas (nombre, fecha de nacimiento*sexo, peso actual y foto).
    * **RF05:** El sistema debe mostrar un catálogo predefinido de especies y razas al momento de registrar una mascota, mostrando la descripció*y foto referencial de la raza.

* Gestión de Consultas (Agendamiento y Atención):
    * **RF06:** El sistema debe permitir al cliente agendar una consulta médica, seleccionando a la mascota, el veterinario, uno de los horarios disponibles y redactando el motivo de la visita.
    * **RF07:** El sistema debe asignar automáticamente el estado "Pendiente" a toda nueva consulta generada por un cliente.
    * **RF08:** El sistema debe permitir al veterinario visualizar una lista de las consultas que tiene agendadas.
    * **RF09:** El sistema debe permitir al veterinario cambiar el estado de la consulta (ej. Confirmada, En curso, Completada, Cancelada).
    * **RF10:** El sistema debe permitir al veterinario registrar los datos médicos de una consulta en curso o completada, incluyendo diagnóstico, tratamiento recetado y las especialidades aplicadas. Al guardar, el sistema generará automáticamente un cronograma de medicación en la base de datos.
    * **RF11:** El sistema debe permitir al veterinario subir y visualizar documentos adjuntos (archivos o imágenes como radiografías) vinculados a la consulta.
    * **RF12:** El sistema debe permitir al cliente visualizar el historial completo de consultas médicas de sus mascotas, incluyendo el detalle de diagnósticos, tratamientos recetados y documentos adjuntos (archivos o imágenes) proporcionados por el veterinario, una vez que la consulta tenga el estado "Completada".

* Sistema de Evaluación:
    * **RF13:** El sistema debe permitir al cliente otorgar una calificación (del 1 al 5) y escribir una reseña únicamente a las consultas que tengan el estado "Completada".

* Adherencia a Tratamientos:
    * **RF14:** El sistema debe permitir al cliente registrar el cumplimiento de cada toma de medicación generada por el cronograma, mediante confirmación desde notificaciones push.
    * **RF15:** El sistema debe permitir al veterinario consultar la tasa de adherencia al tratamiento de cada paciente.

* Alertas Epidemiológicas:
    * **RF16:** Al registrar un diagnóstico contagioso, un trigger en Supabase evaluará la ubicación geográfica del cliente y notificará a los dueños cercanos sobre el brote activo.
    * **RF17:** El sistema debe mostrar un mapa epidemiológico con alertas zonales activas accesible por el cliente.

* Historial Clínico con Autenticidad Criptográfica:
    * **RF18:** Al finalizar una cita crítica (vacunas, cirugías), Supabase generará un hash único (firma digital) del registro médico para garantizar su inmutabilidad.
    * **RF19:** El cliente debe poder generar y verificar el token de autenticidad de un historial clínico para demostrar su validez legal en otras clínicas o viajes internacionales.

* Módulo de Especies Exóticas:
    * **RF20:** El sistema debe permitir registrar seguimiento morfológico de mascotas exóticas, incluyendo fotografías alineadas a lo largo del tiempo para evaluar crecimiento (ej. caparazones de tortugas Mata mata/Taricaya, coloración de invertebrados).
    * **RF21:** El sistema debe permitir gestionar una bóveda legal de documentos de mascotas exóticas, incluyendo facturas de zoocriaderos y certificados CITES que demuestren el origen legal del animal.

### 2. Requerimientos No Funcionales:
* Cómo debe comportarse el sistema (atributos de calidad, restricciones y rendimiento).
    1. **RNF01 (Seguridad):** Las contraseñas de los usuarios deben estar encriptadas en la base de datos (por ejemplo, mediante algoritmos como bcrypt).
    2. **RNF02 (Seguridad/Autorización):** El sistema debe restringir las vistas y acciones según el rol del usuario (ej. un cliente no puede modificar un diagnóstico ni cambiar el estado de la consulta).
    3. **RNF03 (Autenticación):** El sistema debe usar JWT para la autenticación del usuario antes de ejecutar servicios, este token debe ser guardado en "Keychain/Keystore" del móvil y ser enviado en la cabecera (Authorization) en cada petición.
    4. **RNF04 (Rendimiento):** La aplicación móvil debe cargar las vistas principales en menos de 3 segundos bajo una conexión de red estándar (4G/WIFI).
    5. **RNF05 (Almacenamiento):** Las imágenes (fotos de perfil, mascotas, documentos médicos) deben ser comprimidas antes de subirse al servidor para optimizar el espacio y los tiempos de carga.
    6. **RNF06 (Disponibilidad):** Supabase y su base de datos deben garantizar una alta disponibilidad (uptime del 99.9%) al estar gestionados como servicio cloud.
    7. **RNF07 (Usabilidad):** La interfaz debe ser intuitiva y adaptable (Responsive) a diferentes tamaños de pantalla en dispositivos móviles (smartphones y tablets).

## Casos de Uso
Los casos de uso representan las interacciones principales de los actores (Cliente y Veterinario) con el sistema.
* Actor Común: Cliente y Veterinario
    * **CU01 - Registrarse en la app:** El actor completa el formulario para crear su cuenta de usuario con su rol respectivo.
    * **CU02 - Iniciar Sesión:** El actor ingresa sus credenciales para acceder a sus funciones habilitadas.
    * **CU03 - Editar Perfil:** El actor modifica sus datos personales de contacto o actualiza su foto de perfil.
* Actor: Cliente
    * **CU04 - Gestionar Mascotas:** El cliente crea, actualiza o visualiza el historial básico de sus mascotas.
    * **CU05 - Agendar Consulta Médica:** El cliente elige a su mascota, selecciona a un médico de la clínica, escoge uno de los horarios disponibles y envía la solicitud.
    * **CU06 - Visualizar Historial Clínico:** El cliente ingresa al perfil de su mascota y consulta los registros médicos pasados, pudiendo leer las recetas y descargar las radiografías o análisis adjuntos.
    * **CU07 - Evaluar Atención:** Tras finalizar una consulta, el cliente selecciona las estrellas (1-5) y deja un comentario sobre el servicio recibido.
* Actor: Veterinario
    * **CU08 - Gestionar Agenda Médica:** El veterinario visualiza su calendario de citas y actualiza el estado de las consultas solicitadas.
    * **CU09 - Registrar Datos Médicos:** El veterinario ingresa el diagnóstico y el tratamiento de una mascota durante o después de su cita. Al guardar, el sistema genera automáticamente un cronograma de medicación y, si el diagnóstico es contagioso, dispara una alerta epidemiológica por geofencing.
    * **CU10 - Adjuntar Resultados Médicos:** El veterinario sube archivos PDF o imágenes (como análisis de sangre o radiografías) a la consulta específica.
* Actor: Cliente (nuevas funcionalidades)
    * **CU11 - Registrar Cumplimiento de Tratamiento:** El cliente confirma la toma de medicación desde notificaciones push de la app, permitiendo al veterinario ver la tasa de adherencia al tratamiento.
    * **CU12 - Consultar Mapa Epidemiológico / Recibir Alertas Zonales:** El cliente consulta el mapa de brotes activos en su zona o recibe notificaciones push cuando hay un caso contagioso cerca de su dirección registrada.
* Modificaciones a Casos de Uso Existentes:
    * **CU06 (ampliado) - Visualizar Historial Clínico:** Incluye el sub-caso de uso (<<extend>>) **"Generar/Verificar Token de Autenticidad"** para demostrar legalmente la validez del historial en otras clínicas o viajes.
    * **CU04 (ampliado) - Gestionar Mascotas:** Incluye sub-casos (<<include>>) para **"Registrar Seguimiento Morfológico"** (fotos alineadas en el tiempo para evaluar crecimiento en especies exóticas) y **"Gestionar Bóveda Legal"** (facturas de zoocriaderos y certificados CITES).

Puedes encontrar el diagrama de casos de uso en el archivo:
- `use_cases_schema.puml` (ubicado en la raíz del repositorio)

### Diagramas Completos de Casos de Uso

El diagrama PlantUML actualizado (CU01–CU12 con relaciones <<include>> y <<extend>>) se encuentra en:
- `use_cases_schema.puml` (ubicado en la raíz del repositorio)

## Descripción de Casos de Uso

Los casos de uso documentados a continuación corresponden a los requisitos funcionales (RF01–RF21) y están relacionados directamente con el diagrama de base de datos.

#### Casos de Uso Comunes (Cliente y Veterinario)
- **CU01** Registrarse en la app
- **CU02** Iniciar Sesión (Supabase Auth / JWT)
- **CU03** Editar Perfil

#### Casos de Uso - Cliente
- **CU04** Gestionar Mascotas *(incluye: Registrar Seguimiento Morfológico, Gestionar Bóveda Legal CITES)*
- **CU05** Agendar Consulta Médica
- **CU06** Visualizar Historial Clínico *(extiende: Generar/Verificar Token de Autenticidad)*
- **CU07** Evaluar Atención
- **CU11** Registrar Cumplimiento de Tratamiento *(confirma toma de medicación vía push)*
- **CU12** Consultar Mapa Epidemiológico / Recibir Alertas Zonales

#### Casos de Uso - Veterinario
- **CU08** Gestionar Agenda Médica
- **CU09** Registrar Datos Médicos *(trigger: genera cronograma de medicación + alerta epidemiológica si diagnóstico contagioso)*
- **CU10** Adjuntar Resultados Médicos

## Diagrama de Base de Datos (Schema)

Para soportar todos los requisitos funcionales, se diseñó un modelo de entidades relacional que incluye:

- **users y roles**: Gestión de usuarios con autenticación JWT via Supabase Auth (clientes y veterinarios)
- **clients y veterinarians**: Datos específicos por tipo de usuario
- **species y breeds**: Catálogo predefinido de especies y razas
- **pets**: Registro de mascotas con sus atributos (nombre, fecha de nacimiento, sexo, peso, foto)
- **veterinarian_availability**: Disponibilidad semanal de veterinarios con intervalos de tiempo
- **consultations**: Registro de consultas médicas con estado, diagnóstico, tratamiento y hash de autenticidad
- **consultation_documents**: Adjuntos de radiografías y análisis (almacenados en Supabase Storage)
- **consultation_specialties**: Clasificación de especialidades por consulta
- **medication_schedules**: Cronogramas de medicación generados automáticamente desde CU09
- **treatment_adherence**: Registro de cumplimiento de tomas confirmadas por el cliente (CU11)
- **epidemiological_alerts**: Alertas de brotes activos por zona geográfica (CU12)
- **morphological_records**: Fotos alineadas en el tiempo para seguimiento de crecimiento en especies exóticas (CU04)
- **legal_documents**: Bóveda de certificados CITES y facturas de zoocriaderos (CU04)

El diagrama completo se encuentra en: `schema.puml` (ubicado en la raíz del repositorio)

![Diagrama de Base de Datos](Docs/diagrams/schema.png)

---

## Diagrama de Clases
El diagrama de clases muestra las entidades del dominio, sus atributos principales, las relaciones entre ellas y los métodos representativos de negocio.

- Propósito: documentar el dominio y servir como referencia para implementar los `models` y las migraciones.
- Uso recomendado: usarlo como guía; las validaciones, autorizaciones y la lógica completa van en el código fuente.
- Contenido: cada clase representa una entidad del esquema y sus asociaciones muestran cómo se relacionan los datos entre sí.

Clases clave:
- `User`: concentra los datos comunes de autenticación y perfil (via Supabase Auth + JWT).
- `Client` y `Veterinarian`: especializan el usuario según su rol, con RLS en Supabase.
- `Pet`: representa cada mascota. Incluye referencias a `MorphologicalRecord` (seguimiento morfológico) y `LegalDocument` (bóveda CITES).
- `Consultation`: flujo principal de atención médica. Al completarse, genera un `MedicationSchedule` via trigger y, si el diagnóstico es contagioso, una `EpidemiologicalAlert`.
- `ConsultationDocument`: archivos adjuntos almacenados en Supabase Storage.
- `ConsultationSpecialty`: vincula consultas con especialidades clínicas.
- `VeterinarianAvailability`: intervalos de disponibilidad del veterinario.
- `MedicationSchedule` y `TreatmentAdherence`: cronograma de medicación y registro de cumplimiento del cliente (CU11).
- `EpidemiologicalAlert`: alertas de brotes activos por zona geográfica (CU12).
- `MorphologicalRecord`: fotos alineadas en el tiempo para especies exóticas (CU04).
- `LegalDocument`: certificados CITES y facturas de zoocriaderos (CU04).
- `Species`, `Breed` y `Specialty`: catálogos del sistema.

Métodos clave:
- Los métodos del diagrama representan acciones de dominio y reglas de negocio.
- Ejemplos: registro e inicio de sesión en `User`, gestión de mascotas en `Client` y `Pet`, control del ciclo de atención en `Consultation`, adjuntos en `ConsultationDocument` y horarios en `VeterinarianAvailability`.
- El objetivo es mostrar qué responsabilidades tiene cada clase dentro del dominio, no detallar la implementación completa.

Explicación más detallada de los métodos:
- `User.register()` crea una cuenta nueva con los datos base del usuario y su rol.
- `User.login()` valida credenciales y permite el acceso al sistema.
- `User.updateProfile()` actualiza datos de contacto o foto de perfil.
- `User.changePassword()` modifica la contraseña actual por una nueva.
- `Client.listPets()` devuelve las mascotas registradas por ese cliente.
- `Client.createPet()` agrega una nueva mascota asociada al cliente.
- `Veterinarian.listConsultations()` muestra las consultas asignadas al veterinario.
- `Veterinarian.updateConsultationStatus()` cambia el estado de una consulta en curso o pendiente.
- `Veterinarian.listAvailability()` recupera los bloques de horario disponibles.
- `Veterinarian.getAvailableSlots()` calcula los espacios libres según fecha y configuración.
- `Pet.getAge()` calcula la edad de la mascota a partir de su fecha de nacimiento.
- `Pet.updateProfile()` actualiza nombre, peso, foto u otros datos básicos de la mascota.
- `Consultation.create()` inicia una nueva consulta con mascota, veterinario, fecha, hora y motivo.
- `Consultation.confirm()` marca la consulta como confirmada.
- `Consultation.cancel()` cancela la consulta y guarda la razón.
- `Consultation.complete()` cierra la atención registrando diagnóstico y tratamiento.
- `Consultation.attachDocument()` asocia un documento médico a la consulta.
- `Consultation.addSpecialty()` relaciona la consulta con una especialidad clínica.
- `Consultation.rate()` guarda la calificación y comentario del cliente.
- `ConsultationDocument.upload()` representa la carga de un archivo médico.
- `ConsultationDocument.delete()` elimina un documento adjunto.
- `ConsultationSpecialty.add()` crea la relación entre una consulta y una especialidad.
- `ConsultationSpecialty.remove()` elimina esa relación.
- `VeterinarianAvailability.listForVeterinarian()` obtiene la agenda disponible de un veterinario.
- `VeterinarianAvailability.activate()` habilita un bloque de disponibilidad.
- `VeterinarianAvailability.deactivate()` deshabilita un bloque de disponibilidad.
- `Species.listAll()`, `Breed.listBySpecies()` y `Specialty.listAll()` recuperan catálogos del sistema para usarse en formularios y consultas.

![Diagrama de Clases (métodos representativos)](Docs/diagrams/class_diagram_v2.png)

---

## Diagrama de Despliegue

La arquitectura del sistema está compuesta por:

1. **Dispositivo Móvil**: Aplicación Flutter con módulo de compresión de imágenes y almacenamiento seguro de JWT en Keychain/Keystore
2. **Supabase Auth**: Autenticación con JWT, gestión de sesiones y control de acceso por roles (RLS – Row Level Security)
3. **Supabase PostgreSQL**: Base de datos relacional gestionada en la nube con triggers para lógica de negocio
4. **Supabase Storage**: Almacenamiento de imágenes, documentos médicos y archivos CITES
5. **Supabase Edge Functions**: Funciones serverless para generación de hashes de autenticidad y notificaciones push

El diagrama de despliegue con mapeo de requisitos no funcionales se encuentra en: `deployment_diagram.puml` (ubicado en la raíz del repositorio)

![Diagrama de Despliegue](Docs/diagrams/deployment_diagram.png)

---

## Mapeo de Requerimientos No Funcionales al Diagrama de Despliegue

| RNF | Descripción | Componente en Diagrama |
|-----|-----------|----------------------|
| **RNF01** | Encriptación de contraseñas (bcrypt) | Módulo de Seguridad en Backend |
| **RNF02** | Control de acceso por rol | Módulo de Seguridad en Backend |
| **RNF03** | Autenticación JWT guardada en Keychain | Keystore en Dispositivo Móvil + Supabase Auth |
| **RNF04** | Rendimiento < 3 segundos | SDK Supabase con caché + Red HTTPS |
| **RNF05** | Compresión de imágenes antes de subir | Módulo de Compresión en Dispositivo Móvil → Supabase Storage |
| **RNF06** | Alta disponibilidad 99.9% | Supabase Cloud (PostgreSQL gestionado) |
| **RNF07** | Interfaz responsive | Aplicación Flutter (multiplataforma) |

## Mockups (Prototipos de Interfaz)

Los prototipos de interfaz están siendo rediseñados para adaptarse a las nuevas funcionalidades core.
