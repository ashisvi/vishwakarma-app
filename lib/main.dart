import 'package:flutter/material.dart';
import 'package:vishwakarma_yuva_sangathan_app/screens/home_feed_screen.dart';

import 'screens/language_selection_screen.dart';
import 'theme/app_theme.dart';

void main() {
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
      home: const HomeFeedScreen(),
    );
  }
}
