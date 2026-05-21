import 'package:get/get.dart';

/// App-wide translations for EN and ES.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Auth
          'sign_in': 'SIGN IN',
          'sign_up': 'SIGN UP',
          'email': 'EMAIL',
          'password': 'PASSWORD',
          'first_name': 'FIRST NAME',
          'last_name': 'LAST NAME',
          'phone': 'PHONE',
          'confirm_password': 'CONFIRM PASSWORD',
          'no_account': "Don't have an account?",
          'create_here': 'Create one here',
          'forgot_password': 'Forgot your password?',
          'already_account': 'Already have an account?',
          'login_here': 'Login here',
          // Navigation
          'home': 'Home',
          'my_pets': 'My Pets',
          'history': 'History',
          'profile': 'Profile',
          // Pets
          'add_pet': 'ADD PET',
          'pet_name': 'PET NAME',
          'species': 'SPECIES',
          'breed': 'BREED',
          'birth_date': 'BIRTH DATE',
          'weight': 'WEIGHT (kg)',
          'sex': 'SEX',
          'microchip': 'MICROCHIP',
          'exotic': 'EXOTIC SPECIES',
          'save': 'SAVE',
          'cancel': 'CANCEL',
          // Consultation
          'book_appointment': 'BOOK APPOINTMENT',
          'select_vet': 'SELECT VETERINARIAN',
          'select_date': 'SELECT DATE',
          'select_time': 'SELECT TIME',
          'reason': 'REASON',
          'confirm': 'CONFIRM',
          // Clinical history
          'clinical_history': 'CLINICAL HISTORY',
          'integrity_verified': 'RECORD INTEGRITY VERIFIED',
          'integrity_failed': 'INTEGRITY COMPROMISED',
          // Medications
          'medication_adherence': 'MEDICATION ADHERENCE',
          'mark_taken': 'MARK AS TAKEN',
          // Alerts
          'epidemiological_alerts': 'EPIDEMIOLOGICAL ALERTS',
          // Profile
          'dark_mode': 'Dark mode',
          'light_mode': 'Light mode',
          'language': 'Language',
          'settings': 'Settings',
          'appearance': 'Appearance',
          'select_language': 'Select your language.',
          'logout': 'LOG OUT',
          // Messages
          'error_empty_fields': 'Please fill in all required fields.',
          'error_passwords_mismatch': 'Passwords do not match.',
          'success_registered': 'Account created successfully.',
          'success_pet_added': 'Pet added successfully.',
          'success_appointment_booked': 'Appointment booked.',
        },
        'es_ES': {
          // Auth
          'sign_in': 'INICIAR SESIÓN',
          'sign_up': 'REGISTRARSE',
          'email': 'CORREO',
          'password': 'CONTRASEÑA',
          'first_name': 'NOMBRE',
          'last_name': 'APELLIDO',
          'phone': 'TELÉFONO',
          'confirm_password': 'CONFIRMAR CONTRASEÑA',
          'no_account': '¿No tienes una cuenta?',
          'create_here': 'Créala aquí',
          'forgot_password': '¿Olvidaste tu contraseña?',
          'already_account': '¿Ya tienes una cuenta?',
          'login_here': 'Inicia sesión aquí',
          // Navigation
          'home': 'Inicio',
          'my_pets': 'Mis mascotas',
          'history': 'Historial',
          'profile': 'Perfil',
          // Pets
          'add_pet': 'AGREGAR MASCOTA',
          'pet_name': 'NOMBRE',
          'species': 'ESPECIE',
          'breed': 'RAZA',
          'birth_date': 'FECHA NACIMIENTO',
          'weight': 'PESO (kg)',
          'sex': 'SEXO',
          'microchip': 'MICROCHIP',
          'exotic': 'ESPECIE EXÓTICA',
          'save': 'GUARDAR',
          'cancel': 'CANCELAR',
          // Consultation
          'book_appointment': 'AGENDAR CITA',
          'select_vet': 'SELECCIONAR VETERINARIO',
          'select_date': 'SELECCIONAR FECHA',
          'select_time': 'SELECCIONAR HORA',
          'reason': 'MOTIVO',
          'confirm': 'CONFIRMAR',
          // Clinical history
          'clinical_history': 'HISTORIAL CLÍNICO',
          'integrity_verified': 'INTEGRIDAD DEL REGISTRO VERIFICADA',
          'integrity_failed': 'INTEGRIDAD COMPROMETIDA',
          // Medications
          'medication_adherence': 'ADHERENCIA MEDICAMENTOS',
          'mark_taken': 'MARCAR COMO TOMADO',
          // Alerts
          'epidemiological_alerts': 'ALERTAS EPIDEMIOLÓGICAS',
          // Profile
          'dark_mode': 'Modo oscuro',
          'light_mode': 'Modo claro',
          'language': 'Idioma',
          'settings': 'Configuración',
          'appearance': 'Apariencia',
          'select_language': 'Selecciona tu idioma.',
          'logout': 'CERRAR SESIÓN',
          // Messages
          'error_empty_fields': 'Por favor completa todos los campos.',
          'error_passwords_mismatch': 'Las contraseñas no coinciden.',
          'success_registered': 'Cuenta creada exitosamente.',
          'success_pet_added': 'Mascota agregada exitosamente.',
          'success_appointment_booked': 'Cita agendada.',
        },
      };
}
