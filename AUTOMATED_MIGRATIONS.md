# Automatización de Supabase - Migraciones Automáticas

## Problema Original
Antes: Copiar/pegar SQL manual cada vez en Supabase Dashboard 😑
Ahora: **Las migraciones se ejecutan automáticamente** ✅

---

## 🎯 Opción 1: Local + Manual (Recomendado para Ahora)

### Paso 1: Instalar Supabase CLI
```bash
# Si no lo tienes instalado
npm install -g @supabase/cli

# Verificar instalación
supabase --version
```

### Paso 2: Autenticarse
```bash
# Primera vez solamente
supabase login

# Te abrirá navegador para confirmar
# Completa la autenticación
```

### Paso 3: Crear .env.local
```bash
# Copia el template
cp .env.local.example .env.local

# Edita .env.local y agrega:
# Tu Project ID: Supabase Dashboard → Settings → General → Reference ID
# Tu Service Role Key: Supabase Dashboard → Settings → API → Service role key
```

Contenido de `.env.local`:
```bash
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_PROJECT_REF=YOUR_PROJECT_ID
```

### Paso 4: Ejecutar Migraciones
```bash
# Una sola vez para inicializar
cd prograMovil

# Ejecutar script de deploy
chmod +x deploy.sh
./deploy.sh dev

# Sigue las instrucciones que muestra
```

**Resultado**: Todas las tablas, datos y políticas se crean automáticamente ✓

### Paso 5: Cada Vez que Actualizes Código
```bash
# Después de hacer cambios
git add .
git commit -m "feat: mi cambio"

# Ejecutar migraciones (si hay cambios en la BD)
./deploy.sh dev
```

---

## 🚀 Opción 2: GitHub Actions (Automatización Completa)

**Esto ejecuta migraciones automáticamente cada vez que haces push a GitHub**

### Paso 1: Subir Código a GitHub
```bash
# Si no lo tienes ya
git init
git add .
git commit -m "initial commit"
git branch -M main

# Agregar remoto
git remote add origin https://github.com/TU_USER/vetcare.git
git push -u origin main
```

### Paso 2: Agregar Secrets a GitHub
1. Abre tu repo en GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Agrega 3 secrets (copia de tu `.env.local`):

**Secret 1**:
- Name: `SUPABASE_ACCESS_TOKEN`
- Value: Obtén de: `supabase projects list --api` (token que muestra)

**Secret 2**:
- Name: `SUPABASE_PROJECT_REF`
- Value: Tu project ID (ej: `abcdef123456`)

**Secret 3** (opcional):
- Name: `SUPABASE_DB_PASSWORD`
- Value: Tu contraseña de la BD (en Settings → Database)

### Paso 3: El Workflow Se Activa Automáticamente

**Ahora cada vez que hagas push:**
```bash
git add .
git commit -m "feat: breed API"
git push origin main
```

**GitHub Actions hace automáticamente**:
1. ✅ Descarga el código
2. ✅ Se conecta a Supabase
3. ✅ Ejecuta las migraciones
4. ✅ Verifica que funcione
5. ✅ Notifica en el repo si falla

**Ves el progreso en**:
GitHub → Tu repo → **"Actions"** → Último workflow

---

## 📁 Estructura de Migraciones

```
prograMovil/
├── supabase/
│   └── migrations/
│       ├── 20260521000000_initial_schema.sql
│       ├── 20260522000000_add_new_table.sql  (futuro)
│       └── 20260523000000_add_indexes.sql    (futuro)
├── .env.local              (Tu máquina, no subir a Git)
├── .env.local.example      (Template para otros)
├── deploy.sh               (Script local)
└── .github/
    └── workflows/
        └── deploy-supabase.yml  (GitHub Actions)
```

---

## ✅ Crear Una Nueva Migración

Cuando necesites actualizar la BD:

### Paso 1: Crear Archivo
```bash
# El nombre sigue el patrón: YYYYMMDDHHMMSS_descripcion.sql
# Ejemplo: 20260522150000_add_phone_field.sql

touch supabase/migrations/20260522000000_add_phone_field.sql
```

### Paso 2: Escribir SQL
```sql
-- supabase/migrations/20260522000000_add_phone_field.sql
-- Add new phone field to users

ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS phone2 text;
CREATE INDEX IF NOT EXISTS idx_users_phone2 ON users(phone2);

-- Verificación
SELECT 'Migration 20260522000000 complete!' as status;
```

### Paso 3: Ejecutar Localmente
```bash
./deploy.sh dev

# O manualmente:
# Copia el SQL y pégalo en Supabase SQL Editor
```

### Paso 4: Push a GitHub
```bash
git add supabase/migrations/20260522000000_add_phone_field.sql
git commit -m "chore: add phone2 field migration"
git push origin main

# GitHub Actions ejecuta automáticamente
```

---

## 🔄 Cómo Funciona la Automatización

### Trigger (Qué Causa la Automatización)
```yaml
on:
  push:
    branches: [main, develop]  # Se ejecuta al hacer push
  workflow_dispatch:            # O manualmente desde GitHub
```

### Pasos que GitHub Actions Ejecuta
```yaml
1. Checkout code          ← Descarga tu código
2. Setup Node             ← Instala Node.js
3. Install Supabase CLI   ← Instala herramienta
4. Verify connection      ← Conecta con Supabase
5. Apply migrations       ← Ejecuta SQL
6. Verify schema          ← Verifica que funcionó
7. Notify on failure      ← Alerta si hay error
```

---

## 📊 Ver Estado de Migraciones

### En GitHub
```
GitHub → Actions → Último workflow
├── Successful ✅ (verde)
└── Failed ❌ (rojo)
```

### En Supabase
```
Supabase Dashboard → Database → Tables
├── users
├── pets
├── breeds
├── species
├── epidemiological_alerts
```

---

## 🆘 Solución de Problemas

### Error: "SUPABASE_ACCESS_TOKEN not set"
**Solución**: Agregaste los secrets a GitHub? Settings → Secrets

### Error: "Migration failed"
**Solución**:
1. Verifica el SQL está correcto
2. Ejecuta localmente: `./deploy.sh dev`
3. Revisa logs en GitHub Actions

### Migraciones No Se Ejecutan en GitHub
**Solución**:
1. Verifica el archivo está en `supabase/migrations/`
2. Verifica el nombre sigue el patrón: `YYYYMMDDHHMMSS_*.sql`
3. Haz un nuevo commit y push

---

## 🎯 Resumen

| Situación | Acción |
|-----------|--------|
| **Desarrollo Local** | `./deploy.sh dev` + manual en Supabase si es rápido |
| **Cambios en BD** | Crear archivo en `supabase/migrations/` |
| **Colaboradores** | Push a GitHub → Actions ejecuta automáticamente |
| **Producción** | `./deploy.sh prod` (con confirmación) |

---

## 💡 Tips

### Tip 1: No Subas .env.local a Git
```bash
# Verifica que esté en .gitignore
echo ".env.local" >> .gitignore
git rm --cached .env.local 2>/dev/null || true
```

### Tip 2: Versionear Migraciones
```bash
# Siempre usa timestamp diferente
20260521000000_initial_schema.sql
20260522000000_add_breed_id.sql       ← Más reciente
20260523000000_add_alerts.sql         ← Más reciente aún
```

### Tip 3: Migraciones Son Inmutables
```bash
# Nunca edites una migración que ya ejecutaste
# Crea una nueva migración en su lugar
```

---

## ⚡ Workflow Final

```
1. Actualizo código en VS Code
2. Tests locales: `flutter run`
3. BD necesita cambios:
   a. Creo archivo en supabase/migrations/
   b. Escribo SQL
   c. Ejecuto: ./deploy.sh dev
4. Todo funciona:
   a. git add .
   b. git commit -m "feat: ..."
   c. git push origin main
5. GitHub Actions ejecuta automáticamente:
   ✅ Conecta a Supabase
   ✅ Ejecuta migraciones
   ✅ Notifica si falla
6. ¡Listo!
```

---

**Ya no necesitas copiar/pegar manual. ¡Automatizado! 🚀**
