import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SwipeToConfirm extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String label;

  const SwipeToConfirm({
    super.key,
    required this.onConfirmed,
    this.label = 'Swipe to confirm dose',
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> {
  double _dragPosition = 0;
  bool _isConfirmed = false;
  String? _confirmedTime;
  final double _threshold = 0.85;
  final double _thumbSize = 56.0;

  @override
  void initState() {
    super.initState();
    _dragPosition = 0;
  }

  void _onPointerDown(PointerDownEvent details) {
    if (_isConfirmed) return;
    setState(() => _dragPosition = 0);
  }

  void _onPointerMove(PointerMoveEvent details, double maxDrag) {
    if (_isConfirmed) return;
    
    final newPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    final progress = newPosition / maxDrag;

    if (progress >= _threshold && !_isConfirmed) {
      _confirmDose();
    } else {
      setState(() => _dragPosition = newPosition);
    }
  }

  void _onPointerUp(PointerUpEvent details) {
    if (_isConfirmed) return;
    
    if (_dragPosition < 200) {
      setState(() => _dragPosition = 0);
    }
  }

  void _confirmDose() {
    HapticFeedback.heavyImpact();
    
    setState(() {
      _isConfirmed = true;
      _confirmedTime = DateFormat('HH:mm').format(DateTime.now());
    });

    widget.onConfirmed();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConfirmed = false;
          _confirmedTime = null;
          _dragPosition = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - _thumbSize;
        final progress = _dragPosition / maxDrag;

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: (details) => _onPointerMove(details, maxDrag),
          onPointerUp: _onPointerUp,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Progress fill
                if (progress > 0 && !_isConfirmed)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _dragPosition,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),

                // Confirmed fill
                if (_isConfirmed)
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),

                // Center label
                Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      letterSpacing: 0.12,
                      color: _isConfirmed ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(
                      _isConfirmed
                          ? '— Dose confirmed · $_confirmedTime —'
                          : widget.label,
                    ),
                  ),
                ),

                // Thumb (draggable handle)
                if (!_isConfirmed)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    left: _dragPosition,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: _thumbSize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
