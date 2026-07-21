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
import 'pages/book_appointment/book_appointment_controller.dart';
import 'pages/clinical_history/clinical_history_page.dart';
import 'pages/medication_adherence/medication_adherence_page.dart';
import 'pages/epidemiological_map/epidemiological_map_page.dart';
import 'pages/vet_dashboard/vet_dashboard_page.dart';
import 'pages/register_medical/register_medical_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/verify_email/verify_email_page.dart';
import 'pages/pre_consultation/pre_consultation_page.dart';
import 'pages/consultation_documents/consultation_documents_page.dart';
import 'pages/review_consultation/review_consultation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final appController = Get.put(AppController());
  await appController.loadPreferences();
  runApp(VetCareApp(appController: appController));
}

class VetCareApp extends StatelessWidget {
  final AppController appController;
  const VetCareApp({super.key, required this.appController});

  @override
  Widget build(BuildContext context) => Obx(() => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VetCare',

        // Theme
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: appController.selectedThemeMode,

        // Translations
        translations: AppTranslations(),
        locale: appController.selectedLocale,
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

        // Routes
        initialRoute: AppRoutes.splash,
        getPages: [
          GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
          GetPage(name: AppRoutes.signIn, page: () => SignInPage()),
          GetPage(name: AppRoutes.signUp, page: () => SignUpPage()),
          GetPage(
              name: AppRoutes.verifyEmail, page: () => const VerifyEmailPage()),
          GetPage(name: AppRoutes.homeClient, page: () => const HomePage()),
          GetPage(name: AppRoutes.addPet, page: () => AddPetPage()),
          GetPage(name: AppRoutes.petProfile, page: () => PetProfilePage()),
          GetPage(
            name: AppRoutes.bookAppointment,
            page: () => const BookAppointmentPage(),
            binding: BindingsBuilder(
              () => Get.lazyPut<BookAppointmentController>(
                () => BookAppointmentController(),
                fenix: true,
              ),
            ),
          ),
          GetPage(
              name: AppRoutes.clinicalHistory,
              page: () => const ClinicalHistoryPage()),
          GetPage(
              name: AppRoutes.medicationAdherence,
              page: () => MedicationAdherencePage()),
          GetPage(
              name: AppRoutes.epidemiologicalMap,
              page: () => EpidemiologicalMapPage()),
          GetPage(
              name: AppRoutes.vetDashboard,
              page: () => const VetDashboardPage()),
          // Backwards-compatible alias kept in AppRoutes.
          GetPage(
              name: AppRoutes.homeVet, page: () => const VetDashboardPage()),
          GetPage(
              name: AppRoutes.registerMedical,
              page: () => RegisterMedicalPage()),
          GetPage(name: AppRoutes.profile, page: () => ProfilePage()),
          GetPage(name: AppRoutes.settings, page: () => SettingsPage()),
          GetPage(
              name: AppRoutes.preConsultation,
              page: () => const PreConsultationPage()),
          GetPage(
              name: AppRoutes.consultationDocuments,
              page: () => ConsultationDocumentsPage()),
          GetPage(
              name: AppRoutes.reviewConsultation,
              page: () => ReviewConsultationPage()),
        ],
      ));
}
