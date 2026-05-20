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
      final profile = await _fetchProfile(uid);
      return GenericResponse(success: true, data: profile, message: 'Welcome back!');
    } on AuthException catch (e) {
      return GenericResponse(success: false, message: e.message, error: e.toString());
    } catch (e) {
      return GenericResponse(success: false, message: 'Unexpected error.', error: e.toString());
    }
  }

  Future<GenericResponse<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String role = 'client',
  }) async {
    try {
      final res = await _sb.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      final uid = res.user?.id;
      if (uid == null) {
        return const GenericResponse(success: false, message: 'Registration failed.');
      }
      // The DB trigger handle_new_auth_user already inserts users/clients/veterinarians rows.
      // We upsert users here as a fallback in case the trigger is not configured, but
      // we never manually insert into clients/veterinarians — the trigger handles that
      // correctly and a manual insert would violate the unique constraint on user_id.
      try {
        await _sb.from('users').upsert({
          'id': uid,
          'email': email.trim(),
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        });
      } catch (_) {
        // Trigger already created the row — ignore duplicate/conflict errors.
      }
      final profile = await _fetchProfile(uid);
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
        .select()
        .eq('id', uid)
        .single();
    return AppUser.fromJson(data);
  }
}
