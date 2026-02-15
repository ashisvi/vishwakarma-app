import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initializeSupabase() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
}

SupabaseClient get supabase => Supabase.instance.client;

// Send OTP to the provided phone number. Returns true if OTP was sent successfully, false otherwise.
Future<bool> signInWithPhone(String phoneWithCountryCode) async {
  try {
    await supabase.auth.signInWithOtp(phone: phoneWithCountryCode);
    debugPrint("OTP sent to $phoneWithCountryCode");
    return true;
  } on AuthException catch (error) {
    // Log or rethrow as needed.
    debugPrint("AuthException: ${error.message}");
    return false;
  } catch (error) {
    debugPrint("Unexpected error: $error");
    return false;
  }
}

// Verify OTP and sign in the user. Returns true if successful, false otherwise.
Future<bool> verifyOtp(String phoneWithCountryCode, String token) async {
  try {
    final AuthResponse res = await supabase.auth.verifyOTP(
      type: OtpType.sms,
      phone: phoneWithCountryCode,
      token: token,
    );
    final session = (res as dynamic)?.session;
    return session != null;
  } catch (e) {
    return false;
  }
}

Future<void> signOut() async => await supabase.auth.signOut();
