import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime initialDate;

  const DatePicker({
    super.key,
    required this.onDateSelected,
    DateTime? initialDate,
  }) : initialDate = initialDate ?? const DateTime(2024, 5, 19);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime selectedDate;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: Row(
        children: [
          for (int i = -3; i <= 10; i++)
            Padding(
              padding: EdgeInsets.only(
                left: i == -3 ? 22 : 6,
                right: i == 10 ? 22 : 0,
              ),
              child: _buildDateTile(
                selectedDate.add(Duration(days: i)),
                isSelected: selectedDate.day == selectedDate.add(Duration(days: i)).day,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTile(DateTime date, {required bool isSelected}) {
    final dayName = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1];
    
    return GestureDetector(
      onTap: () {
        setState(() => selectedDate = date);
        widget.onDateSelected(date);
      },
      child: Container(
        width: 56,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                letterSpacing: 0.12,
                color: isSelected ? Colors.white : Colors.black.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
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
    );
  }
}
