import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'components/app_controller.dart';
import 'configs/app_routes.dart';
import 'configs/app_translations.dart';
import 'configs/supabase_config.dart';
import 'configs/theme.dart';

// Pages
import 'pages/splash/splash_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/home/home_page.dart';
import 'pages/add_pet/add_pet_page.dart';
import 'pages/pet_profile/pet_profile_page.dart';
import 'pages/book_appointment/book_appointment_page.dart';
import 'pages/clinical_history/clinical_history_page.dart';
import 'pages/medication_adherence/medication_adherence_page.dart';
import 'pages/epidemiological_map/epidemiological_map_page.dart';
import 'pages/vet_dashboard/vet_dashboard_page.dart';
import 'pages/register_medical/register_medical_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/verify_email/verify_email_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const VetCareApp());
  // Force GetX locale so translations resolve correctly after hot reload
  WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.updateLocale(const Locale('es', 'ES')));
}

class VetCareApp extends StatelessWidget {
  const VetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VetCare',

      // Theme
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,

      // Translations
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('es', 'ES'),

      // Flutter localizations (for date/time pickers)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],

      // Global controller
      initialBinding: BindingsBuilder(() {
        Get.put(AppController());
      }),

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
        GetPage(name: AppRoutes.signIn, page: () => SignInPage()),
        GetPage(name: AppRoutes.signUp, page: () => SignUpPage()),
        GetPage(name: AppRoutes.verifyEmail, page: () => const VerifyEmailPage()),
        GetPage(name: AppRoutes.homeClient, page: () => HomePage()),
        GetPage(name: AppRoutes.addPet, page: () => AddPetPage()),
        GetPage(name: AppRoutes.petProfile, page: () => PetProfilePage()),
        GetPage(name: AppRoutes.bookAppointment, page: () => BookAppointmentPage()),
        GetPage(name: AppRoutes.clinicalHistory, page: () => ClinicalHistoryPage()),
        GetPage(name: AppRoutes.medicationAdherence, page: () => MedicationAdherencePage()),
        GetPage(name: AppRoutes.epidemiologicalMap, page: () => EpidemiologicalMapPage()),
        GetPage(name: AppRoutes.vetDashboard, page: () => VetDashboardPage()),
        GetPage(name: AppRoutes.registerMedical, page: () => RegisterMedicalPage()),
        GetPage(name: AppRoutes.profile, page: () => ProfilePage()),
        GetPage(name: AppRoutes.settings, page: () => SettingsPage()),
      ],
    );
  }
}
