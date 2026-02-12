import 'package:flutter/material.dart';
import 'package:vishwakarma_yuva_sangathan_app/theme/app_theme.dart';

import './posts/home_feed_screen.dart';
import './donations/donation_dashboard_screen.dart';
import './profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeFeedScreen(),
    DonationDashboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primarySaffron.withOpacity(0.95),
              borderRadius: BorderRadius.circular(50),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: AppColors.whiteCard,
              unselectedItemColor: AppColors.creamBackground,
              backgroundColor: Colors.transparent,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded, size: 35),
                  label: 'होम',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_rounded, size: 35),
                  label: 'दान',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
