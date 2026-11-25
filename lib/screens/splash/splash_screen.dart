import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../navigation/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAndNavigate());
  }

  Future<void> _initializeAndNavigate() async {
    setState(() => _initError = null);
    try {
      final appProvider = context.read<AppProvider>();

      try {
        await appProvider.storage.init();
      } catch (_) {
        // Fallback cleanly if SharedPreferences is unavailable
      }
      await appProvider.initialize();

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _initError = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.precision_manufacturing_rounded,
                            size: 38,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConstants.appShortName,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mechatronics English',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.appSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_initError != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Lỗi khởi tạo: $_initError',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _initializeAndNavigate,
                      child: const Text('Thử lại'),
                    ),
                  ] else
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
