import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.onTap,
    required this.themeName,
    required this.cardColor,
    this.duration = const Duration(milliseconds: 280),
  });

  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback onTap;
  final String themeName;
  final Color cardColor;
  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    if (widget.isFlipped) {
      _ctrl.forward();
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle = _anim.value * math.pi;
          final showFront = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: _CardFace(
              flip: showFront,
              themeName: widget.themeName,
              cardColor: widget.cardColor,
              child: showFront ? widget.front : widget.back,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.child, 
    required this.flip, 
    required this.themeName,
    required this.cardColor,
  });
  
  final Widget child;
  final bool flip;
  final String themeName;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = Color.fromRGBO(
      (cardColor.r * 255.0).round() & 0xff,
      (cardColor.g * 255.0).round() & 0xff,
      (cardColor.b * 255.0).round() & 0xff,
      0.3,
    );
    
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(flip ? math.pi : 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cardColor,
          boxShadow: kElevationToShadow[3],
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(child: child),
      ),
    );
  }
}
