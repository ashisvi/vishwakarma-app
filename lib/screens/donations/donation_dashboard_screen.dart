import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';
import 'donation_amount_screen.dart';
import 'transaction_details_screen.dart';

String formatTransactionDate(String? createdAt) {
  if (createdAt == null) return '';
  try {
    final dt = DateTime.parse(createdAt).toLocal();
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return createdAt;
  }
}

class DonationDashboardScreen extends StatefulWidget {
  const DonationDashboardScreen({super.key});

  @override
  State<DonationDashboardScreen> createState() =>
      _DonationDashboardScreenState();
}

class _DonationDashboardScreenState extends State<DonationDashboardScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final txs = await fetchTransactions();
      double bal = 0;
      for (var tx in txs) {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
        final isCredit = tx['type'] == 'credit';
        if (tx['status'] == 'success') {
          if (isCredit) {
            bal += amount;
          } else {
            bal -= amount;
          }
        }
      }
      if (mounted) {
        setState(() {
          _transactions = txs;
          _balance = bal;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load transactions';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openDonationAmount() async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => const DonationAmountScreen()),
    );
    if (result == true) {
      _fetchTransactions();
    }
  }

  String _formatDate(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

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
              'दान पात्र',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'Donations',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SummaryCard(balance: _balance, isLoading: _isLoading),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: GoogleFonts.notoSans(color: Colors.red),
                      ),
                    )
                  : _transactions.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions yet',
                            style: GoogleFonts.notoSans(color: AppColors.maroon),
                          ),
                        )
                      : _TransactionList(
                          transactions: _transactions,
                          onOpenDetails: (tx) => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailsScreen(
                                amount: (tx['amount'] as num).toDouble(),
                                isCredit: tx['type'] == 'credit',
                                status: tx['status'] as String? ?? '',
                                dateTimeLabel: _formatDate(
                                  tx['created_at']?.toString(),
                                ),
                                description: tx['description'] as String? ?? '',
                                paymentReferenceId: tx['upi_ref'] as String? ?? '',
                                addedBy: tx['created_by'] as String? ?? '',
                                userData: tx['users'] as Map<String, dynamic>?,
                              ),
                            ),
                          ),
                        ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDonationAmount,
        backgroundColor: AppColors.primarySaffron,
        foregroundColor: AppColors.whiteCard,
        icon: const Icon(Icons.volunteer_activism),
        label: Text(
          'Donate',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.balance, required this.isLoading});

  final double balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            const SizedBox(
              height: 38,
              width: 38,
              child: CircularProgressIndicator(color: AppColors.maroon),
            )
          else
            Text(
              '₹ ${balance.toStringAsFixed(0)}',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.maroon,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'समाज कोष शेष राशि / Society fund balance',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: AppColors.maroon.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Total verified donations collected so far',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.maroon.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.onOpenDetails,
  });

  final List<Map<String, dynamic>> transactions;
  final void Function(Map<String, dynamic>) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionCard(
          transaction: tx,
          onTap: () => onOpenDetails(tx),
        );
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, this.onTap});

  final Map<String, dynamic> transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = (transaction['type'] as String? ?? '') == 'credit';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
    final dateTimeLabel = transaction['created_at']?.toString() ?? '';
    final description = transaction['description'] as String? ?? '';
    final donorNameItem = transaction['users'];
    final donorName = (donorNameItem != null && donorNameItem is Map) 
        ? donorNameItem['name'] as String? 
        : null;
        
    final defaultTitle = (donorName != null && donorName.isNotEmpty) 
        ? donorName 
        : 'Donation';
        
    final amountColor = isCredit ? Colors.green.shade700 : Colors.red.shade700;
    final sign = isCredit ? '+' : '-';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      defaultTitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.maroon,
                      ),
                    ),
                    if (description.isNotEmpty && description != 'Donation') ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: AppColors.maroon.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      formatTransactionDate(dateTimeLabel),
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.maroon.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign₹${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCredit ? 'Credit' : 'Debit',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: AppColors.maroon.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
