import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatefulWidget {
  final String status; // 'completed', 'in-progress', 'pending'
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.status == 'in-progress') {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.status == 'in-progress') {
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == 'completed') {
      return _buildCompletedBadge();
    } else if (widget.status == 'in-progress') {
      return _buildInProgressBadge();
    } else {
      return _buildPendingBadge();
    }
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmall ? 8 : 12,
        vertical: widget.isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'COMPLETED',
            style: GoogleFonts.jetBrainsMono(
              fontSize: widget.isSmall ? 8 : 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmall ? 8 : 12,
        vertical: widget.isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'IN-PROGRESS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: widget.isSmall ? 8 : 10,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmall ? 8 : 12,
        vertical: widget.isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PENDING',
        style: GoogleFonts.jetBrainsMono(
          fontSize: widget.isSmall ? 8 : 10,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.12,
        ),
      ),
    );
  }
}
