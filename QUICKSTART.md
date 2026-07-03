# ⚡ SETUP COMPLETO: Google Maps + Supabase Automático

## 🚀 Para Empezar Ahora (5 minutos)

### A. Google Maps API Key (1 minuto)

**Lee**: [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) - Pasos 1-3

Resumen rápido:
```
1. https://console.cloud.google.com
2. Crear proyecto "VetCare"
3. Habilitar: Maps SDK Android + iOS
4. Crear API Key
5. Copiar key a:
   - android/app/src/main/AndroidManifest.xml
   - ios/Runner/Info.plist
```

### B. Supabase Migraciones Automáticas (4 minutos)

**Lee**: [AUTOMATED_MIGRATIONS.md](AUTOMATED_MIGRATIONS.md) - Opción 1

Resumen rápido:
```bash
# 1. Instalar CLI
npm install -g @supabase/cli

# 2. Autenticarse
supabase login

# 3. Copiar config
cp .env.local.example .env.local
# (Edita y agrega tu Project ID)

# 4. Ejecutar
chmod +x deploy.sh
./deploy.sh dev
```

---

## 📋 Checklist Completo

- [ ] **Google Cloud Console**
  - [ ] Crear proyecto
  - [ ] Habilitar Maps SDK Android
  - [ ] Habilitar Maps SDK iOS
  - [ ] Crear API Key
  - [ ] Agregar SHA-1 en restricciones (Android)
  - [ ] Configurar límites de gasto

- [ ] **Android Setup**
  - [ ] Copiar API Key a `AndroidManifest.xml`
  - [ ] Verificar `<meta-data>` dentro de `<application>`

- [ ] **iOS Setup**
  - [ ] Copiar API Key a `Info.plist`
  - [ ] Verificar dentro de `<dict>`

- [ ] **Supabase CLI**
  - [ ] `npm install -g @supabase/cli`
  - [ ] `supabase login`
  - [ ] Crear `.env.local` con credenciales

- [ ] **Migraciones**
  - [ ] `./deploy.sh dev`
  - [ ] Verificar en Supabase Dashboard → Tables

- [ ] **GitHub Actions** (Opcional)
  - [ ] Subir código a GitHub
  - [ ] Agregar Secrets
  - [ ] Verificar workflow en Actions

- [ ] **Test en App**
  - [ ] `flutter run -d emulator-5554`
  - [ ] Ir a "EPIDEMIOLOGICAL MAP"
  - [ ] Ver mapa cargado ✓

---

## 📞 Soporte

### Problema: "Maps API not enabled"
**Solución**: [GOOGLE_MAPS_SETUP.md - Sección 2.1](GOOGLE_MAPS_SETUP.md)

### Problema: "Migration failed"
**Solución**: [AUTOMATED_MIGRATIONS.md - Solución de Problemas](AUTOMATED_MIGRATIONS.md)

### Problema: "API Key rejected"
**Solución**: [GOOGLE_MAPS_SETUP.md - Solución de Problemas](GOOGLE_MAPS_SETUP.md)

---

## 💰 Resumen de Costos

| Servicio | Costo | Detalles |
|----------|-------|---------|
| **Google Maps** | $0-50/mes | $200 gratis/mes + $7 por 1000 requests |
| **Supabase** | $0-25/mes | 500 MB gratis + $5 por GB |
| **GitHub Actions** | $0 | 2000 minutos gratis/mes |
| **TOTAL** | **~$0-50/mes** | Para una app pequeña |

---

## 🔄 Flujo de Trabajo Diario

```
┌─────────────────────────────────────────────────────┐
│ 1. Desarrollo                                       │
│    - Editar código                                  │
│    - flutter run -d emulator-5554                   │
│    - Probar cambios                                 │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ 2. Si BD necesita cambios                           │
│    - Crear: supabase/migrations/TIMESTAMP_*.sql    │
│    - Escribir SQL                                   │
│    - ./deploy.sh dev                                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ 3. Commit & Push                                    │
│    - git add .                                      │
│    - git commit -m "feat: ..."                      │
│    - git push origin main                           │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ 4. GitHub Actions (Automático)                      │
│    ✅ Conecta a Supabase                            │
│    ✅ Ejecuta migraciones                           │
│    ✅ Notifica si falla                             │
│    ✅ ¡Listo!                                       │
└─────────────────────────────────────────────────────┘
```

---

## 📚 Documentos de Referencia

1. **[GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md)** - Setup completo de Google Maps
2. **[AUTOMATED_MIGRATIONS.md](AUTOMATED_MIGRATIONS.md)** - Automatización de Supabase
3. **[.github/workflows/deploy-supabase.yml](.github/workflows/deploy-supabase.yml)** - GitHub Actions
4. **[deploy.sh](deploy.sh)** - Script local de deploy
5. **[supabase/migrations/](supabase/migrations/)** - Archivos de migraciones

---

## ✅ Validación

Después de completar todo:

```bash
# 1. Verificar migraciones en Supabase
#    Dashboard → Database → Tables
#    Deberías ver: users, pets, breeds, species, epidemiological_alerts

# 2. Verificar Google Maps en app
#    flutter run -d emulator-5554
#    Menu → Epidemiological Map
#    Debería mostrarse mapa con alertas

# 3. Verificar GitHub Actions
#    GitHub → Actions
#    Último workflow debería estar green (✅)
```

---

## 🎉 ¡Listo!

- ✅ Google Maps API configurado (sin costo)
- ✅ Migraciones automáticas en cada push
- ✅ Base de datos siempre actualizada
- ✅ Sin copiar/pegar manual

**Próximo paso**: Puedes enfocarte 100% en features, no en infra 🚀
