import 'package:flutter/material.dart';

import '.././services/supabase_service.dart';
import '../theme/app_theme.dart';

import './posts/home_feed_screen.dart';
import './donations/donation_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isUserAdmin = false;
  bool _loadingAdminStatus = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final admin = await isUserAdmin();
    if (mounted) {
      setState(() {
        _isUserAdmin = admin;
        _loadingAdminStatus = false;
      });
    }
  }

  List<Widget> get _screens => [
    HomeFeedScreen(isAdmin: _isUserAdmin),
    const DonationDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final double _bottomReserve =
        MediaQuery.of(context).viewPadding.bottom + 86.0;

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: _bottomReserve),
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),

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
