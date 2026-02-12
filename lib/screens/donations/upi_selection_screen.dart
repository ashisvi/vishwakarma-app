import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class UpiSelectionScreen extends StatefulWidget {
  const UpiSelectionScreen({super.key});

  @override
  State<UpiSelectionScreen> createState() => _UpiSelectionScreenState();
}

class _UpiSelectionScreenState extends State<UpiSelectionScreen> {
  String? _selectedApp;

  final List<_UpiApp> _apps = const [
    _UpiApp(id: 'gpay', name: 'Google Pay'),
    _UpiApp(id: 'phonepe', name: 'PhonePe'),
    _UpiApp(id: 'paytm', name: 'Paytm'),
    _UpiApp(id: 'bhim', name: 'BHIM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'UPI ऐप चुनें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'Choose UPI app',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _apps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = _apps[index];
                  final selected = _selectedApp == app.id;
                  return _buildAppCard(app, selected);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(_UpiApp app, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _selectedApp = app.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primarySaffron
                : AppColors.primarySaffron.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAppLogo(app),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                app.name,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.maroon,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primarySaffron),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo(_UpiApp app) {
    // Placeholder colored circle; replace with actual logos via Image.asset
    Color bg;
    switch (app.id) {
      case 'gpay':
        bg = Colors.blue.shade600;
        break;
      case 'phonepe':
        bg = Colors.purple.shade600;
        break;
      case 'paytm':
        bg = Colors.lightBlue.shade600;
        break;
      case 'bhim':
        bg = Colors.green.shade700;
        break;
      default:
        bg = AppColors.primarySaffron;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: bg,
      child: Text(
        app.name[0],
        style: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.whiteCard,
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    final canPay = _selectedApp != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: canPay ? _onPayNow : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          disabledBackgroundColor: AppColors.primarySaffron.withValues(
            alpha: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pay Now'),
            const SizedBox(width: 8),
            Text(
              'अभी भुगतान करें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPayNow() {
    if (_selectedApp == null) return;
    // TODO: Trigger UPI intent for selected app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'UPI भुगतान प्रक्रिया शुरू होगी',
          style: GoogleFonts.notoSansDevanagari(fontSize: 14),
        ),
        backgroundColor: AppColors.maroon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _UpiApp {
  const _UpiApp({required this.id, required this.name});

  final String id;
  final String name;
}
