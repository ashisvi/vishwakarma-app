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

// Posts functionality moved to posts_service.dart

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

/// Check if the currently authenticated user has a profile row in `users` table.
Future<bool> userHasProfile() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    final resp = await supabase
        .from('users')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    return resp != null;
  } catch (e) {
    debugPrint('userHasProfile error: $e');
    return false;
  }
}

/// Fetch the current user's profile from `users` table.
/// Returns a Map of profile fields or null when not found.
Future<Map<String, dynamic>?> fetchUserProfile() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final resp = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (resp == null) return null;
    return Map<String, dynamic>.from(resp as Map);
  } catch (e) {
    debugPrint('fetchUserProfile error: $e');
    return null;
  }
}

/// Insert or update profile for current user. `data` should include fields like
/// name, father_name, phone, village, block, district, address, etc.
/// Returns true when upsert succeeded.
Future<bool> upsertUserProfile(Map<String, dynamic> data) async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    // Ensure id is set to user's id
    data['id'] = user.id;
    await supabase.from('users').upsert(data);
    debugPrint('upsertUserProfile: Profile saved successfully');
    return true;
  } catch (e) {
    debugPrint('upsertUserProfile exception: $e');
    return false;
  }
}

/// Fetch locations by type (e.g., 'state', 'district', 'block', 'village').
/// Optionally filter by parent_id for hierarchical relationships.
Future<List<Map<String, dynamic>>> fetchLocations({
  required String type,
  String? parentId,
}) async {
  try {
    var query = supabase.from('locations').select('id, name, type, parent_id');
    query = query.eq('type', type).eq('is_active', true);
    if (parentId != null) {
      query = query.eq('parent_id', parentId);
    } else {
      query = query.isFilter('parent_id', null);
    }
    // query = query.order('name', ascending: true);
    final resp = await query;
    return List<Map<String, dynamic>>.from(resp as List);
  } catch (e) {
    debugPrint('fetchLocations error: $e');
    return [];
  }
}

/// Fetch a single location row by its `id` from `locations` table.
/// Returns the location map (including `name`) or null if not found.
Future<Map<String, dynamic>?> fetchLocationById(String id) async {
  try {
    final resp = await supabase
        .from('locations')
        .select('id, name, type, parent_id')
        .eq('id', id)
        .maybeSingle();
    if (resp == null) return null;
    return Map<String, dynamic>.from(resp as Map);
  } catch (e) {
    debugPrint('fetchLocationById error: $e');
    return null;
  }
}

/// Check if the current user is an admin.
/// Returns true if user's role is 'admin', false otherwise.
Future<bool> isUserAdmin() async {
  try {
    final profile = await fetchUserProfile();
    if (profile == null) return false;
    final role = profile['role'] as String?;
    return role == 'admin';
  } catch (e) {
    debugPrint('isUserAdmin error: $e');
    return false;
  }
}
