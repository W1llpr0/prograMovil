/// Supabase project constants.
/// Replace the URL and ANON KEY with your actual project values.
class SupabaseConfig {
  /// Configure at build/run time:
  /// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  ///
  /// The checked-in defaults keep the current development project working,
  /// while CI and production can inject their own public credentials.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lqfuubsexsljpsxlzokz.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_kGGBFUuZF17oU3Myw3TbEA_tIj5LqEl',
  );

  static bool get isConfigured =>
      Uri.tryParse(url)?.hasScheme == true && anonKey.trim().isNotEmpty;

  // Storage bucket names
  static const String petImagesBucket = 'pet-images';
  static const String consultationDocsBucket = 'consultation-docs';
  static const String legalDocsBucket = 'legal-docs';
}
