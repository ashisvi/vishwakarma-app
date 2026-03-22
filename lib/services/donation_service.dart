import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> fetchTransactions() async {
  try {
    final res = await _supabase
        .from('transactions')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res as List);
  } catch (e) {
    debugPrint('fetchTransactions error: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>?> createDonationIntent(double amount) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final res = await _supabase
        .from('donation_intents')
        .insert({'user_id': user.id, 'amount': amount, 'status': 'initiated'})
        .select()
        .maybeSingle();

    if (res == null) return null;
    return Map<String, dynamic>.from(res as Map);
  } catch (e) {
    debugPrint('createDonationIntent error: $e');
    rethrow;
  }
}

Future<bool> markIntentSuccess(String intentId, String upiRef) async {
  try {
    final res = await _supabase
        .from('donation_intents')
        .update({'status': 'success', 'upi_ref': upiRef})
        .eq('id', intentId);
    return (res != null);
  } catch (e) {
    debugPrint('markIntentSuccess error: $e');
    return false;
  }
}

Future<bool> markIntentFailed(String intentId) async {
  try {
    final res = await _supabase
        .from('donation_intents')
        .update({'status': 'failed'})
        .eq('id', intentId);
    return (res != null);
  } catch (e) {
    debugPrint('markIntentFailed error: $e');
    return false;
  }
}

Future<Map<String, dynamic>?> createTransaction(
  double amount,
  String upiRef,
) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final res = await _supabase
        .from('transactions')
        .insert({
          'type': 'credit',
          'amount': amount,
          'status': 'success',
          'mode': 'upi',
          'description': 'Donation',
          'upi_ref': upiRef,
          'created_by': user.id,
        })
        .select()
        .maybeSingle();

    if (res == null) return null;
    return Map<String, dynamic>.from(res as Map);
  } catch (e) {
    debugPrint('createTransaction error: $e');
    rethrow;
  }
}
