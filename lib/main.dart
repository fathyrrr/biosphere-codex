import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/hero_screen.dart';
import 'ui/screens/codex_explorer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090D16),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BiosphereCodexApp());
}

class BiosphereCodexApp extends StatelessWidget {
  const BiosphereCodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biosphere Codex',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _AppRouter(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF090D16),
      primaryColor: const Color(0xFF10B981),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981),
        secondary: Color(0xFF38BDF8),
        surface: Color(0xFF0F172A),
        background: Color(0xFF090D16),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFF1F5F9),
        displayColor: const Color(0xFFF1F5F9),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0F1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: const TextStyle(color: Color(0xFFE2E8F0)),
        side: const BorderSide(color: Color(0xFF334155)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

/// Router utama aplikasi — mengelola urutan layar:
/// Splash → Hero → CodexExplorer
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  _Screen _currentScreen = _Screen.splash;

  void _goToHero() {
    setState(() => _currentScreen = _Screen.hero);
  }

  void _goToExplorer() {
    setState(() => _currentScreen = _Screen.explorer);
  }

  void _goBackToHero() {
    setState(() => _currentScreen = _Screen.hero);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      child: switch (_currentScreen) {
        _Screen.splash => SplashScreen(
            key: const ValueKey('splash'),
            onComplete: _goToHero,
          ),
        _Screen.hero => HeroScreen(
            key: const ValueKey('hero'),
            onEnterCodex: _goToExplorer,
          ),
        _Screen.explorer => CodexExplorerScreen(
            key: const ValueKey('explorer'),
            onBackToHero: _goBackToHero,
          ),
      },
    );
  }
}

enum _Screen { splash, hero, explorer }
