import 'package:flutter/material.dart';
import 'package:vishwakarma_yuva_sangathan_app/screens/auth/login_screen.dart';
import 'package:vishwakarma_yuva_sangathan_app/screens/profile/profile_setup_screen.dart';

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

      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final session = supabase.auth.currentSession;

    if (session != null) {
      final user = session.user;
      return FutureBuilder(
        future: supabase.from('users').select().eq('id', user.id).maybeSingle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const MainNavigationScreen();
          }

          return const ProfileSetupScreen();
        },
      );
    }

    return const LoginScreen();
  }
}
