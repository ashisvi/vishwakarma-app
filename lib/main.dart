import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  await initializeSupabase();
  runApp(const VishwakarmaYuvaSangathanApp());
}

class VishwakarmaYuvaSangathanApp extends StatelessWidget {
  const VishwakarmaYuvaSangathanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vishwakarma Yuva Sangathan',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primarySaffron,
          secondary: AppColors.maroon,
          surface: AppColors.creamBackground,
          onPrimary: AppColors.whiteCard,
          onSecondary: AppColors.whiteCard,
          onSurface: AppColors.maroon,
        ),
        scaffoldBackgroundColor: AppColors.creamBackground,
        useMaterial3: true,
      ),

      home: const MainNavigationScreen(),
    );
  }
}
