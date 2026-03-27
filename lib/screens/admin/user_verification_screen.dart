import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class UserVerificationScreen extends StatefulWidget {
  const UserVerificationScreen({super.key});

  @override
  State<UserVerificationScreen> createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingUsers = [];
  List<Map<String, dynamic>> _verifiedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final pending = await fetchPendingMembers();
      final verified = await fetchVerifiedMembers();
      if (mounted) {
        setState(() {
          _pendingUsers = pending;
          _verifiedUsers = verified;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user, bool initiallyVerified) {
    bool isVerified = user['is_verified'] ?? initiallyVerified;
    String role = user['role'] ?? 'member';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    user['name'] ?? 'Unknown User',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Phone: ${user['phone']}'),
                  Text('Village: ${user['village'] ?? 'N/A'}'),
                  const SizedBox(height: 24),

                  // Verification Switch
                  SwitchListTile(
                    title: const Text('Is Verified'),
                    subtitle: const Text('Verified users appear in the directory'),
                    value: isVerified,
                    activeThumbColor: AppColors.primarySaffron,
                    onChanged: (val) {
                      setSheetState(() => isVerified = val);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  Text('User Role', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'member', child: Text('Member')),
                      DropdownMenuItem(value: 'committee', child: Text('Committee')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => role = val);
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        final success = await updateUserVerification(user['id'], isVerified, role);
                        if (success) {
                          await _fetchUsers();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User updated successfully'), backgroundColor: Colors.green),
                            );
                          }
                        } else {
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update user'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: Text('Save Changes', style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, bool isVerifiedTab) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'No ${isVerifiedTab ? 'verified' : 'pending'} users found.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        final role = user['role'] ?? 'member';
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primarySaffron.withOpacity(0.2),
              child: Text(
                (user['name'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              user['name'] ?? 'Unknown',
              style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${user['phone']}'),
                if (role != 'member')
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: AppColors.maroon, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
            onTap: () => _showEditUserDialog(user, isVerifiedTab),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.primarySaffron,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.whiteCard),
          title: Column(
            children: [
              Text(
                'User Verification',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteCard,
                ),
              ),
              Text(
                'उपयोगकर्ता सत्यापन',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  color: AppColors.whiteCard.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppColors.whiteCard,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.whiteCard,
            tabs: [
              Tab(text: 'PENDING'),
              Tab(text: 'VERIFIED'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primarySaffron))
            : TabBarView(
                children: [
                  _buildUserList(_pendingUsers, false),
                  _buildUserList(_verifiedUsers, true),
                ],
              ),
      ),
    );
  }
}
