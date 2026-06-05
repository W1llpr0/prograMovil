# Google Maps API Setup - Guía Paso a Paso

## ⚠️ COSTOS

**Google Maps es GRATIS para la mayoría de casos:**

- **Primeros 200 dólares al mes**: COMPLETAMENTE GRATIS
- Después: $7 USD por cada 1000 requests (si pasas $200)
- Para una app pequeña: **$0 - $50/mes máximo** (recomendado habilitar límites)

### Ejemplo de Costo Real:
```
30,000 requests/mes = 30 x $7 = $210/mes
⚠️ Pero tienes $200 de crédito gratuito
= $10 solo de tu bolsillo

Para VetCare (app pequeña): ~$0-20/mes
```

**Cómo evitar sorpresas:**
- Habilita límites de gasto
- Usa API key con restricciones (solo Android/iOS)
- Configura alertas si el uso sube

---

## 🚀 PASO 1: Crear Cuenta en Google Cloud

### 1.1 Ir a Google Cloud Console
1. Abre: https://console.cloud.google.com
2. Si no tienes cuenta Google, crea una
3. Si tienes múltiples cuentas, selecciona la correcta

### 1.2 Crear Proyecto Nuevo
1. Click en el selector de proyecto (esquina superior izquierda)
   - Muestra: "Select a project" o nombre de proyecto actual
2. Click en **"NEW PROJECT"**
3. Llena:
   - **Project name**: `VetCare` (o lo que quieras)
   - **Organization**: Deja vacío si no tienes
   - **Location**: Deja predeterminado
4. Click **"CREATE"**
5. Espera ~1 minuto a que se cree
6. Click **"SELECT PROJECT"** cuando esté listo

### 1.3 Habilitar Billing (Necesario)
1. En la barra lateral izquierda: **"Billing"**
2. Click **"LINK A BILLING ACCOUNT"**
3. Click **"CREATE BILLING ACCOUNT"**
4. Selecciona:
   - **Tipo de cuenta**: Individual
   - **País**: Tu país
   - **Nombre**: Tu nombre
5. Llena info de tarjeta de crédito
   - **IMPORTANTE**: Google NO cobrará nada si estás en el rango gratuito
   - La tarjeta solo se valida, no se cobra automáticamente
6. Click **"START MY FREE TRIAL"**
7. Espera a que se activen los créditos ($300 de prueba + $200 mensuales después)

---

## 🔑 PASO 2: Obtener Google Maps API Key

### 2.1 Habilitar Google Maps API
1. En la barra de búsqueda superior, busca: `"Maps SDK for Android"`
2. Click en el resultado
3. Click **"ENABLE"** (color azul)
4. Espera a que se active (2-3 segundos)
5. **Repite este proceso para estos servicios** (búscalos uno por uno):
   - `"Maps SDK for iOS"`
   - `"Maps SDK for Web"` (si lo necesitas)
   - `"Geocoding API"` (opcional, pero útil)

### 2.2 Crear API Key
1. En la barra lateral: **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** (arriba)
3. Selecciona **"API Key"**
4. Se crea automáticamente y muestra un popup
5. **COPIA la key** (será algo como: `AIzaSyD_Cv9...`)
6. Click **"CLOSE"**

### 2.3 Restricciones (IMPORTANTE - Mejora Seguridad)
1. En la lista de credenciales, click en tu API key
2. En **"API restrictions"**:
   - Selecciona: **"Restrict key"**
   - Elige:
     - `Maps SDK for Android`
     - `Maps SDK for iOS`
     - `Maps SDK for Web` (si la necesitas)
3. En **"Application restrictions"**:
   - Selecciona: **"Android apps"** (o iOS/Web según corresponda)
   - Click **"+ Add an Android app"**
   - Necesitarás: `Package name` + `SHA-1 certificate fingerprint`
   - Deja vacío por ahora si no lo tienes
4. Click **"SAVE"**

### 2.4 Obtener SHA-1 (Para Android - Obligatorio)
```bash
# En la carpeta raíz del proyecto Flutter:
./gradlew signingReport

# Busca en el output:
# "SHA-1: XXXX:XXXX:XXXX:..."

# Copia ese valor y pégalo en Google Cloud Console
```

---

## 🛠️ PASO 3: Configurar en Flutter

### 3.1 Android (AndroidManifest.xml)
```xml
<!-- File: android/app/src/main/AndroidManifest.xml -->

<manifest>
  <application
    android:label="VetCare"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Add this line -->
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="AIzaSyD_Cv9_______PEGÁ_TU_API_KEY_AQUÍ_______"/>
    
    <!-- ... resto del contenido ... -->
  </application>
</manifest>
```

**Ubicación exacta**: 
```
android/app/src/main/AndroidManifest.xml
                     ↓ (dentro del <application> tag)
                   <meta-data>
```

### 3.2 iOS (Info.plist)
```xml
<!-- File: ios/Runner/Info.plist -->

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Add these lines -->
  <key>GMSApiKey</key>
  <string>AIzaSyD_Cv9_______PEGÁ_TU_API_KEY_AQUÍ_______</string>
  
  <!-- ... resto del contenido ... -->
</dict>
</plist>
```

**Ubicación exacta**:
```
ios/Runner/Info.plist
          ↓ (dentro del <dict> tag)
        <key>GMSApiKey</key>
        <string>TU_API_KEY</string>
```

### 3.3 Usar en Dart (Ya está implementado)
```dart
// En epidemiological_map_page.dart (YA ESTÁ)
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: const LatLng(-12.0464, -77.0428), // Lima
    zoom: 12,
  ),
  // ... más propiedades
)
```

---

## 💰 PASO 4: Configurar Límites de Gasto (Para No Sorpresas)

### 4.1 Budget Alerts
1. Google Cloud Console → **"Billing"** → **"Budgets and alerts"**
2. Click **"CREATE BUDGET"**
3. Llena:
   - **Budget name**: `VetCare Alerts`
   - **Budget amount**: `$50` (ajusta según tu presupuesto)
4. En **"Alerts and notifications"**:
   - Email: tu correo
   - Alertar cuando: `80%` y `100%` del presupuesto
5. Click **"CREATE"**

### 4.2 Capping (Detiene si pasas límite)
1. En el proyecto: **"APIs & Services"** → **"Quotas"**
2. Busca: `"Maps SDK for Android - Requests per day"`
3. Click → **"EDIT QUOTAS"**
4. Establece un máximo (ej: 10,000 requests/día)
5. Click **"SAVE"**

---

## ✅ PASO 5: Verificar que Funciona

### 5.1 Test en Android
```bash
cd app
flutter clean
flutter run -d emulator-5554
```

Debería:
1. Compilar sin errores
2. Cargar app en emulator
3. Navegar a "EPIDEMIOLOGICAL MAP"
4. Ver mapa con alertas ✓

### 5.2 Test en iOS (Si tienes Mac)
```bash
cd app
flutter run -d iPhone-simulator
```

---

## 🚨 Solución de Problemas

### Error: "Maps API not enabled"
**Solución**: Vuelve a Paso 2.1 y habilita `Maps SDK for Android/iOS`

### Error: "Invalid API Key"
**Soluciones**:
1. Verifica que copiaste TODA la key correctamente
2. Espera 5-10 minutos después de crear la key
3. Verifica que la key no esté en `Constraints`

### Error: "Authentication failed"
**Solución**: 
- Android: Verifica SHA-1 en Google Cloud Console
- iOS: Verifica `Info.plist` tiene key exacta

### No se ve el mapa, solo gris
**Soluciones**:
1. Verifica ubicación en AndroidManifest.xml (dentro de `<application>`)
2. Verifica el key en Info.plist
3. Reinicia emulator: `adb -e reboot`

---

## 📊 Monitorear Uso

### Ver Cuánto Estás Usando
1. Google Cloud → **"Billing"** → **"Billing overview"**
2. Busca: `"Maps SDK for Android"` en la lista de servicios
3. Verás:
   - Requests usados este mes
   - Costo actual
   - Proyección de costo

### Exportar Datos de Uso
1. **"Billing"** → **"Cost Management"**
2. Descarga CSV para análisis

---

## 🎯 Resumen Rápido

```
COSTO: $0 (primeros $200/mes son gratis)
SETUP: 10 minutos
UBICACIONES ARCHIVOS:
  Android: android/app/src/main/AndroidManifest.xml
  iOS:     ios/Runner/Info.plist
RESTRICCIONES: Sí, configura por app (Android/iOS)
LIMITE DIARIO: Configura en Quotas para evitar sorpresas
TEST: flutter run → Navigate a Epidemiological Map
```

---

## ❓ Preguntas Frecuentes

**P: ¿Necesito tarjeta de crédito?**
R: Solo para verificación. No se cobra si usas menos de $200/mes.

**P: ¿Qué pasa si paso el límite?**
R: A) Se detiene automáticamente (si configuraste caps)
   B) Se te cobra a la tarjeta (configura alertas para evitar)

**P: ¿Puedo usar la misma key en Android e iOS?**
R: Sí, pero es más seguro crear una por plataforma.

**P: ¿El key se puede compartir?**
R: No. Mantenlo privado. Si lo filtras, cualquiera puede usarlo.

**P: ¿Cómo actualizo el key en la app sin recompilar?**
R: No es fácil en Flutter. Mejor hardcodear en los archivos de config.

---

¡Listo! Ya tienes Google Maps funcionando sin costo. 🚀
