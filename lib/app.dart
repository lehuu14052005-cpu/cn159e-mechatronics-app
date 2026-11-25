import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/splash/splash_screen.dart';

class Cn159eApp extends StatelessWidget {
  const Cn159eApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.themeMode,
      theme: AppTheme.lightTheme(seedColor: appProvider.seedColor),
      darkTheme: AppTheme.darkTheme(seedColor: appProvider.seedColor),
      home: const SplashScreen(),
    );
  }
}
