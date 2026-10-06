import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
        _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
          final role = auth.user?.role;
          if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else if (role == 'barber') {
              Navigator.pushReplacementNamed(context, '/barber-dashboard');
          } else {
              Navigator.pushReplacementNamed(context, '/home');
          }
      } else {
          Navigator.pushReplacementNamed(context, '/login');
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left Blade
                    Transform.rotate(
                      angle: -_animation.value,
                      origin: const Offset(0, 20),
                      child: const ScissorBlade(isLeft: true),
                    ),
                    // Right Blade
                    Transform.rotate(
                      angle: _animation.value,
                      origin: const Offset(0, 20),
                      child: const ScissorBlade(isLeft: false),
                    ),
                    // Pivot Screw
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)]
                      ),
                    )
                  ],
                );
              },
            ),
            const SizedBox(height: 50),
            Text(
              'BARBER APP',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScissorBlade extends StatelessWidget {
  final bool isLeft;
  const ScissorBlade({super.key, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(isLeft ? 1.0 : -1.0, 1.0), // Mirror if right
      child: CustomPaint(
        size: const Size(60, 150),
        painter: BladePainter(),
      ),
    );
  }
}

class BladePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    
    final handlePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final path = Path();
    
    // Blade Shape
    path.moveTo(size.width * 0.6, size.height * 0.4); // Pivot area
    path.lineTo(size.width * 0.9, 0); // Tip
    path.cubicTo(size.width * 0.4, 0, size.width * 0.3, size.height * 0.3, size.width * 0.4, size.height * 0.4);
    path.close();

    canvas.drawPath(path, paint);

    // Handle Loop
    final handlePath = Path();
    handlePath.addOval(Rect.fromCenter(center: Offset(size.width * 0.3, size.height * 0.7), width: 40, height: 50));
    canvas.drawPath(handlePath, handlePaint);
    
    // Connector from pivot to handle
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.4), Offset(size.width * 0.35, size.height * 0.6), handlePaint..strokeWidth=8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
