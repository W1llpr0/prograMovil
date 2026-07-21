import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../configs/generic_response.dart';
import '../models/app_user.dart';

class AuthService {
  static const String invalidCredentialsMessage =
      'Correo o contraseña incorrectos.';

  final SupabaseClient? _providedClient;

  AuthService({SupabaseClient? client}) : _providedClient = client;

  @visibleForTesting
  AuthService.detached() : _providedClient = null;

  SupabaseClient get _sb => _providedClient ?? Supabase.instance.client;

  Future<GenericResponse<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    if (!_looksLikeEmail(email) || password.isEmpty) {
      return const GenericResponse(
        success: false,
        code: 'INVALID_CREDENTIALS',
        message: invalidCredentialsMessage,
      );
    }
    try {
      final response = await _sb.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const GenericResponse(
          success: false,
          code: 'AUTH_FAILED',
          message: 'No se pudo iniciar sesión.',
        );
      }
      AppUser profile;
      try {
        profile = await _fetchProfile(user.id);
      } catch (error) {
        debugPrint('Profile fallback for ${user.id}: $error');
        profile = _fromAuthUser(user, fallbackEmail: email.trim());
      }
      return GenericResponse(
        success: true,
        data: profile,
        code: 'SIGNED_IN',
        message: 'Bienvenido.',
      );
    } on AuthException catch (error) {
      // Authentication failures deliberately share one response so the UI
      // cannot be used to enumerate registered email addresses.
      debugPrint(
          'Sign-in rejected by Supabase (${error.statusCode ?? 'auth'}).');
      return const GenericResponse(
        success: false,
        code: 'INVALID_CREDENTIALS',
        message: invalidCredentialsMessage,
      );
    } catch (error) {
      debugPrint('Sign-in connection error: ${error.runtimeType}.');
      return const GenericResponse(
        success: false,
        code: 'SIGN_IN_ERROR',
        message: 'No se pudo conectar con el servidor.',
      );
    }
  }

  Future<GenericResponse<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? document,
    String? phone,
    String? address,
    String role = 'client',
  }) async {
    try {
      final response = await _sb.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'role': role == 'veterinarian' ? 'veterinarian' : 'client',
          if (document?.trim().isNotEmpty == true) 'document': document!.trim(),
          if (phone?.trim().isNotEmpty == true) 'phone': phone!.trim(),
          if (address?.trim().isNotEmpty == true) 'address': address!.trim(),
        },
      );
      final user = response.user;
      if (user == null) {
        return const GenericResponse(
          success: false,
          code: 'SIGN_UP_FAILED',
          message: 'No se pudo crear la cuenta.',
        );
      }

      // The security-definer trigger creates public.users and the role profile.
      // With email confirmation enabled there is no session yet, so returning
      // auth metadata is the expected response until the first sign-in.
      AppUser profile;
      try {
        profile = await _fetchProfile(user.id);
      } catch (_) {
        profile = AppUser(
          id: user.id,
          email: email.trim(),
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
          document: document?.trim().isEmpty == true ? null : document?.trim(),
          address: address?.trim().isEmpty == true ? null : address?.trim(),
          role: role == 'veterinarian' ? 'veterinarian' : 'client',
        );
      }
      return GenericResponse(
        success: true,
        data: profile,
        code: response.session == null
            ? 'EMAIL_CONFIRMATION_REQUIRED'
            : 'SIGNED_UP',
        message: response.session == null
            ? 'Cuenta creada. Revisa tu correo para confirmarla.'
            : 'Cuenta creada correctamente.',
      );
    } on AuthException catch (error) {
      debugPrint(
          'Sign-up rejected by Supabase (${error.statusCode ?? 'auth'}).');
      if (error.statusCode == '429') {
        return const GenericResponse(
          success: false,
          code: 'SIGN_UP_RATE_LIMITED',
          message: 'Se alcanzó el límite temporal de correos de confirmación. '
              'Espera una hora e inténtalo nuevamente.',
        );
      }
      return const GenericResponse(
        success: false,
        code: 'SIGN_UP_REJECTED',
        message:
            'No se pudo crear la cuenta. Revisa los datos o inténtalo más tarde.',
      );
    } catch (error) {
      debugPrint('Sign-up connection error: ${error.runtimeType}.');
      return const GenericResponse(
        success: false,
        code: 'SIGN_UP_ERROR',
        message: 'No se pudo crear la cuenta.',
      );
    }
  }

  Future<GenericResponse<void>> signOut() async {
    try {
      await _sb.auth.signOut();
      return const GenericResponse(
        success: true,
        code: 'SIGNED_OUT',
        message: 'Sesión cerrada.',
      );
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'SIGN_OUT_ERROR',
        message: 'No se pudo cerrar la sesión.',
        error: error.toString(),
      );
    }
  }

  Future<AppUser?> currentUser() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.id);
    } catch (_) {
      return _fromAuthUser(user);
    }
  }

  Future<AppUser> _fetchProfile(String uid) async {
    final data = await _sb
        .from('users')
        .select('*, veterinarians(license_number, years_experience)')
        .eq('id', uid)
        .maybeSingle();
    if (data == null) throw StateError('Profile not found.');
    return AppUser.fromJson(data);
  }

  AppUser _fromAuthUser(User user, {String? fallbackEmail}) => AppUser(
        id: user.id,
        email: user.email ?? fallbackEmail ?? '',
        firstName: user.userMetadata?['first_name']?.toString() ?? 'Usuario',
        lastName: user.userMetadata?['last_name']?.toString() ?? '',
        phone: user.userMetadata?['phone']?.toString(),
        document: user.userMetadata?['document']?.toString(),
        address: user.userMetadata?['address']?.toString(),
        role: user.userMetadata?['role']?.toString() == 'veterinarian'
            ? 'veterinarian'
            : 'client',
      );

  static bool _looksLikeEmail(String value) => RegExp(
        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
      ).hasMatch(value.trim());
}
