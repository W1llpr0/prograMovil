import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/app_controller.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  late AppController appCtrl;
  DateTime selectedDate = DateTime.now();
  int? selectedSlot;

  @override
  void initState() {
    super.initState();
    appCtrl = Get.find<AppController>();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book appointment',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.04 * 28,
              ),
            ),
            const SizedBox(height: 20),

            // Empty state: no pets
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.pets_outlined, size: 64, color: Colors.black.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'No pets registered yet',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register a pet in the Pets tab to book an appointment.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.black.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
