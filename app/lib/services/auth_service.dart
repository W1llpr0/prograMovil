import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/generic_response.dart';
import '../models/app_user.dart';

class AuthService {
  final _sb = Supabase.instance.client;

  Future<GenericResponse<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _sb.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final uid = res.user?.id;
      if (uid == null) {
        return const GenericResponse(success: false, message: 'Authentication failed.');
      }
      
      // Try to fetch profile; if it doesn't exist, construct from auth data
      AppUser profile;
      try {
        profile = await _fetchProfile(uid);
      } catch (e) {
        // Profile not found; construct AppUser from available auth data
        print('Profile not found for $uid, constructing from metadata: $e');
        profile = AppUser(
          id: uid,
          email: email.trim(),
          firstName: res.user?.userMetadata?['first_name'] ?? 'User',
          lastName: res.user?.userMetadata?['last_name'] ?? '',
          phone: res.user?.userMetadata?['phone'],
          role: res.user?.userMetadata?['role'] ?? 'client',
        );
      }
      
      return GenericResponse(success: true, data: profile, message: 'Welcome back!');
    } on AuthException catch (e) {
      print('AuthException in signIn: ${e.message}');
      return GenericResponse(success: false, message: e.message, error: e.toString());
    } catch (e) {
      print('Unexpected error in signIn: $e');
      final errorMsg = 'Error: ${e.toString()}';
      return GenericResponse(success: false, message: errorMsg, error: e.toString());
    }
  }

  Future<GenericResponse<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? document,
    String? phone,
    String role = 'client',
  }) async {
    try {
      // 1. Solo registramos la autenticación y enviamos la metadata
      final res = await _sb.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          if (document != null && document.isNotEmpty) 'document': document,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      final uid = res.user?.id;
      if (uid == null) {
        return const GenericResponse(success: false, message: 'Registration failed.');
      }

      // 2. ¡NO HACEMOS UPSERT MANUAL AQUÍ!
      // Confiamos en que el Trigger SQL de tu base de datos tomó la metadata
      // de arriba y ya insertó al usuario en tus tablas de forma segura.

      // 3. Devolvemos el perfil temporal para que la UI sepa que tuvo éxito.
      // Cuando el usuario inicie sesión (signIn), el sistema traerá los datos reales.
      final profile = AppUser(
        id: uid,
        email: email.trim(),
        firstName: firstName,
        lastName: lastName,
        phone: (phone != null && phone.isNotEmpty) ? phone : null,
        role: role,
      );

      return GenericResponse(success: true, data: profile, message: 'Account created.');

    } on AuthException catch (e) {
      return GenericResponse(success: false, message: e.message, error: e.toString());
    } catch (e) {
      return GenericResponse(success: false, message: 'Unexpected error.', error: e.toString());
    }
  }

  Future<GenericResponse<void>> signOut() async {
    try {
      await _sb.auth.signOut();
      return const GenericResponse(success: true, message: 'Signed out.');
    } catch (e) {
      return GenericResponse(success: false, message: 'Sign out failed.', error: e.toString());
    }
  }

  /// Returns the profile of the currently authenticated user, or null.
  Future<AppUser?> currentUser() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    return _fetchProfile(uid);
  }

  Future<AppUser> _fetchProfile(String uid) async {
    final data = await _sb
        .from('users')
        .select('*, veterinarians(license_number, years_experience)')
        .eq('id', uid)
        .maybeSingle();
    if (data == null) throw Exception('Profile not found for uid $uid');
    return AppUser.fromJson(data);
  }
}
