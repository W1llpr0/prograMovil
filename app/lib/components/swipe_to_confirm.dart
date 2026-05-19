import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// Swipe-to-confirm slider matching VetCare mockup.
/// Drag the thumb to the right to confirm; fill expands L→R.
class SwipeToConfirm extends StatefulWidget {
  final String label;
  final bool done;
  final VoidCallback? onDone;

  const SwipeToConfirm({
    super.key,
    this.label = 'SWIPE TO CONFIRM DOSE',
    this.done = false,
    this.onDone,
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> {
  double _progress = 0; // 0..1
  bool _committed = false;
  double _trackWidth = 0;
  static const _thumbSize = 52.0;
  static const _trackHeight = 60.0;
  static const _pad = 4.0;

  @override
  void initState() {
    super.initState();
    _committed = widget.done;
    if (_committed) _progress = 1;
  }

  double get _maxDx => _trackWidth - _thumbSize - _pad * 2;

  void _onDragUpdate(DragUpdateDetails d) {
    if (_committed) return;
    setState(() {
      _progress = ((_progress * _maxDx + d.delta.dx) / _maxDx).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_committed) return;
    if (_progress > 0.85) {
      HapticFeedback.mediumImpact();
      setState(() {
        _committed = true;
        _progress = 1.0;
      });
      Future.delayed(const Duration(milliseconds: 240), () {
        widget.onDone?.call();
      });
    } else {
      setState(() => _progress = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final trackBg = _committed ? Colors.black : Colors.white;
    final trackFg = _committed ? Colors.white : Colors.black;
    final borderColor = isLight ? Colors.black : Colors.white;

    return LayoutBuilder(builder: (ctx, box) {
      _trackWidth = box.maxWidth;
      final thumbDx = (_progress * _maxDx).clamp(0.0, _maxDx > 0 ? _maxDx : 0);

      return GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: trackBg,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                // Fill layer (expands L→R)
                AnimatedAlign(
                  alignment: Alignment.centerLeft,
                  duration: Duration(milliseconds: _committed ? 350 : 0),
                  curve: const Cubic(0.2, 0.8, 0.2, 1),
                  child: FractionallySizedBox(
                    widthFactor: _progress,
                    child: Container(color: Colors.black),
                  ),
                ),
                // Label
                Center(
                  child: Text(
                    _committed ? '— DOSE CONFIRMED —' : widget.label,
                    style: GoogleFonts.jetBrainsMono(fontSize: 10,
                      letterSpacing: 0.22,
                      color: trackFg.withValues(alpha: _committed ? 1 : (1 - _progress * 0.7)),
                    ),
                  ),
                ),
                // Thumb
                AnimatedPositioned(
                  duration: Duration(milliseconds: _committed ? 350 : 0),
                  curve: const Cubic(0.2, 0.8, 0.2, 1),
                  left: _pad + thumbDx,
                  top: _pad,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Icon(
                      _committed ? Icons.check : Icons.arrow_forward,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
