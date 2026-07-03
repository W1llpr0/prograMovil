import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/status_badge.dart';
import '../components/date_picker.dart';

class VetAgenda extends StatefulWidget {
  const VetAgenda({super.key});

  @override
  State<VetAgenda> createState() => _VetAgendaState();
}

class _VetAgendaState extends State<VetAgenda> {
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> appointments = [
    {
      'time': '09:30',
      'pet': 'Max',
      'owner': 'Familia García',
      'type': 'Annual checkup',
      'status': 'completed',
      'duration': 45,
    },
    {
      'time': '10:15',
      'pet': 'Luna',
      'owner': 'Carlos López',
      'type': 'Vaccination',
      'status': 'in-progress',
      'duration': 30,
    },
    {
      'time': '11:00',
      'pet': 'Rex',
      'owner': 'María Sánchez',
      'type': 'Consultation',
      'status': 'pending',
      'duration': 40,
    },
    {
      'time': '14:30',
      'pet': 'Bella',
      'owner': 'Roberto Díaz',
      'type': 'Dental cleaning',
      'status': 'pending',
      'duration': 60,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
            child: DatePicker(
              initialDate: selectedDate,
              onDateSelected: (date) {
                setState(() => selectedDate = date);
              },
            ),
          ),

          // KPI strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildKPIItem('TODAY', '04', 'appointments'),
                  _buildKPIItem('✓', '02', 'completed'),
                  _buildKPIItem('●', '01', 'in-progress'),
                  _buildKPIItem('○', '01', 'pending'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Timeline
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY\'S AGENDA',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    letterSpacing: 0.18,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    // Vertical spine
                    Positioned(
                      left: 7,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    // Appointments
                    Column(
                      children: [
                        for (int i = 0; i < appointments.length; i++)
                          _buildTimelineItem(appointments[i], i == appointments.length - 1),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            color: Colors.black.withValues(alpha: 0.55),
            letterSpacing: 0.08,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> apt, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node
          SizedBox(
            width: 16,
            height: 60,
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apt['time'],
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${apt['duration']} min',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                      StatusBadge(
                        status: apt['status'],
                        isSmall: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    apt['type'],
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${apt['pet']} · ${apt['owner']}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
