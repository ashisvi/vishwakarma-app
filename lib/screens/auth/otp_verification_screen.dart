import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../profile/profile_setup_screen.dart';
import '../main_navigation_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
    this.countryCode = '+91',
  });

  final String? phoneNumber;
  final String countryCode;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 60;
  Timer? _timer;
  static const double _boxSize = 52.0;
  static const double _borderRadius = 8.0;
  static const double _buttonHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
        setState(() {});
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  String get _maskedPhone {
    final digits = (widget.phoneNumber ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return 'XXXXXXXX';
    return 'XXXXXX${digits.substring(digits.length - 4)}';
  }

  String get _subtitle =>
      'Enter the OTP sent to ${widget.countryCode} $_maskedPhone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 32),
                    _buildOtpCard(),
                    const SizedBox(height: 32),
                    _buildVerifyButton(),
                    const SizedBox(height: 20),
                    _buildResendSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 24, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.maroon,
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Text(
        'OTP Verification',
        style: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.maroon,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      _subtitle,
      style: GoogleFonts.notoSans(
        fontSize: 15,
        color: AppColors.maroon.withValues(alpha: 0.85),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOtpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 7),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (i) => _buildOtpBox(i)),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: _boxSize,
      height: _boxSize,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.maroon,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.creamBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: const BorderSide(
              color: AppColors.primarySaffron,
              width: 2.5,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        onTap: () {
          if (_controllers[index].text.isEmpty) return;
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    final otp = _controllers.map((c) => c.text).join();
    final canVerify = otp.length == 6;

    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: FilledButton(
        onPressed: canVerify ? _onVerify : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          disabledBackgroundColor: AppColors.primarySaffron.withValues(
            alpha: 0.45,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text("Verify"),
      ),
    );
  }

  Widget _buildResendSection() {
    final canResend = _resendSeconds <= 0;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: canResend ? _onResendOtp : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primarySaffron,
              disabledForegroundColor: AppColors.primarySaffron.withValues(
                alpha: 0.5,
              ),
              side: BorderSide(
                color: canResend
                    ? AppColors.primarySaffron
                    : AppColors.primarySaffron.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
              ),
              textStyle: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text("Resend OTP"),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          canResend
              ? ''
              : 'Resend OTP in 0:${_resendSeconds.toString().padLeft(2, '0')}',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors.maroon.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _onVerify() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) return;
    final phone = '${widget.countryCode}${widget.phoneNumber ?? ''}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    verifyOtp(phone, otp).then((ok) async {
      Navigator.of(context).pop();
      if (ok) {
        final hasProfile = await userHasProfile();
        if (hasProfile) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP verification failed. Please try again.'),
            backgroundColor: AppColors.maroon,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _onResendOtp() {
    final phone = '${widget.countryCode}${widget.phoneNumber ?? ''}';
    _startResendTimer();
    signInWithPhone(phone).then((ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'OTP पुनः भेजा गया' : 'OTP भेजने में विफल',
            style: GoogleFonts.notoSansDevanagari(fontSize: 14),
          ),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
