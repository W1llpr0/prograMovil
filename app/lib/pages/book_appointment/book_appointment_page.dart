import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime selectedDate = DateTime.now();
  int? selectedSlot;

  final List<Map<String, String>> availableSlots = [
    {'time': '09:00', 'vet': 'Dr. R. Paz'},
    {'time': '10:00', 'vet': 'Dr. R. Paz'},
    {'time': '11:00', 'vet': 'Dr. A. López'},
    {'time': '14:00', 'vet': 'Dr. R. Paz'},
    {'time': '15:00', 'vet': 'Dr. A. López'},
    {'time': '16:00', 'vet': 'Dr. M. García'},
  ];

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

            // Pet selector
            Text(
              'SELECT PET',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                letterSpacing: 0.18,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pets, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Golden Retriever · M',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date selector
            Text(
              'SELECT DATE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                letterSpacing: 0.18,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (ctx, i) {
                  final date = DateTime.now().add(Duration(days: i));
                  final isSelected = selectedDate.day == date.day;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: Container(
                        width: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1],
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                letterSpacing: 0.12,
                                color: isSelected ? Colors.white : Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString().padLeft(2, '0'),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Time slots
            Text(
              'SELECT TIME',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                letterSpacing: 0.18,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: availableSlots.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => setState(() => selectedSlot = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedSlot == i ? Colors.black : Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        availableSlots[i]['time']!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selectedSlot == i ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        availableSlots[i]['vet']!.split('. ').last.split(' ')[0],
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          color: selectedSlot == i ? Colors.white : Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: selectedSlot != null ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Appointment booked: ${availableSlots[selectedSlot!]['time']} with ${availableSlots[selectedSlot!]['vet']}',
                      ),
                    ),
                  );
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedSlot != null ? Colors.black : Colors.grey.withValues(alpha: 0.3),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      'CONFIRM BOOKING',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        letterSpacing: 0.18,
                        color: selectedSlot != null ? Colors.white : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
