# VetCare Flutter

Cliente móvil de VetCare. La aplicación usa Supabase directamente para Auth,
PostgreSQL, funciones RPC y Storage; no requiere un backend intermedio.

## Ejecución

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://TU_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_CLAVE_PUBLICABLE
```

En PowerShell, usa acentos graves en vez de barras invertidas para continuar el
comando. La clave `service_role` no debe usarse en esta aplicación.

## Calidad

```bash
flutter analyze
flutter test
flutter build web
```

El contrato del backend y las instrucciones de despliegue están en
`../supabase/README.md`.
