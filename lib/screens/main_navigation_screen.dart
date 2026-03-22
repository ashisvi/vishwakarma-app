import 'package:flutter/material.dart';

import '.././services/supabase_service.dart';
import '../theme/app_theme.dart';

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
  bool _isUserAdmin = false;

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
      });
    }
  }

  List<Widget> get _screens => [
    HomeFeedScreen(isAdmin: _isUserAdmin),
    const DonationDashboardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Reserve space for the rounded bottom nav.
    final double _bottomReserve =
        MediaQuery.of(context).viewPadding.bottom + 74.0;

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: _bottomReserve),
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            height: 66, // slightly more compact, still keeps tap >=48dp
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primarySaffron.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _NavIconButton(
                    index: 0,
                    currentIndex: _currentIndex,
                    icon: Icons.home_rounded,
                    onTap: (i) => setState(() => _currentIndex = i),
                  ),
                  _NavIconButton(
                    index: 1,
                    currentIndex: _currentIndex,
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: (i) => setState(() => _currentIndex = i),
                  ),
                  _NavIconButton(
                    index: 2,
                    currentIndex: _currentIndex,
                    icon: Icons.person_rounded,
                    onTap: (i) => setState(() => _currentIndex = i),
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

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final Color iconColor = selected
        ? AppColors.primarySaffron
        : AppColors.maroon.withValues(alpha: 0.65);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 66,
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primarySaffron.withValues(alpha: 0.14)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
