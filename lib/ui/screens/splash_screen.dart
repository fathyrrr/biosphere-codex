import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Layar splash animasi singkat yang ditampilkan saat pertama kali app dimuat.
/// Menampilkan logo DNA + judul dengan efek fade & scale, lalu menavigasi ke HeroScreen.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Urutan animasi
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _logoController.forward().then((_) {
        if (!mounted) return;
        _textController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted) return;
            widget.onComplete();
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // Background animated particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, child) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_tree_rounded,
                      size: 44,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, child) => FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BIOSPHERE CODEX',
                        style: GoogleFonts.spaceMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF1F5F9),
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The Taxonomic Tree & Phylogeny Engine',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom version
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (_, child) => Opacity(
                opacity: _textOpacity.value,
                child: child,
              ),
              child: Text(
                'v1.0.0 · Local-First · Offline',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: const Color(0xFF334155),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter untuk partikel latar belakang yang bergerak
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final phase = random.nextDouble() * math.pi * 2;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final radius = 1.0 + random.nextDouble() * 2.5;
      final opacity = (math.sin(progress * math.pi * 2 * speed + phase) * 0.5 + 0.5) * 0.25;

      paint.color = (i % 3 == 0
              ? const Color(0xFF10B981)
              : i % 3 == 1
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF818CF8))
          .withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

