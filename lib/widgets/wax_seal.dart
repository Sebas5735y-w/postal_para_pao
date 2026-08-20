import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Sello de cera que el usuario "rompe" tocándolo — con animación de
/// hundimiento y un pequeño rebote, como quebrar cera de verdad.
class WaxSeal extends StatefulWidget {
  final VoidCallback onBreak;
  final bool broken;

  const WaxSeal({super.key, required this.onBreak, this.broken = false});

  @override
  State<WaxSeal> createState() => _WaxSealState();
}

class _WaxSealState extends State<WaxSeal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.broken) return;
    HapticFeedback.mediumImpact();
    _controller.forward().whenComplete(widget.onBreak);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [AppColors.rust, Color(0xFF6E2A14)],
              center: Alignment(-0.3, -0.3),
              radius: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'P',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: AppColors.cream.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
