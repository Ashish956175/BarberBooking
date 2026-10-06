import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool borderGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0, // Increased blur
    this.opacity = 0.08, // Subtle opacity
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.borderGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: borderGradient 
                  ? Border.all(color: Colors.transparent) // Handled by gradient? No, simple stroke for now to avoid complexity
                  : Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? Colors.white).withOpacity(opacity + 0.05),
                  (color ?? Colors.white).withOpacity(opacity),
                ],
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
              ]
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
