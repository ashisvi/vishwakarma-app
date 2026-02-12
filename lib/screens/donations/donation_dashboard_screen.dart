import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class DonationDashboardScreen extends StatelessWidget {
  const DonationDashboardScreen({super.key});

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
            child: _SummaryCard(balance: 152340.0),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: const _TransactionList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open donation flow
        },
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
  const _SummaryCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primarySaffron,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total balance',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹ ${balance.toStringAsFixed(0)}',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.maroon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'समाज कोष शेष राशि',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: AppColors.maroon.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    final transactions = _demoTransactions;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionCard(transaction: tx);
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final DonationTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == DonationType.credit;
    final amountColor = isCredit ? Colors.green.shade700 : Colors.red.shade700;
    final sign = isCredit ? '+' : '-';

    return Container(
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
                    transaction.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.maroon,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.dateTimeLabel,
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
                  '$sign₹${transaction.amount.toStringAsFixed(0)}',
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
    );
  }
}

enum DonationType { credit, debit }

class DonationTransaction {
  DonationTransaction({
    required this.title,
    required this.dateTimeLabel,
    required this.amount,
    required this.type,
  });

  final String title;
  final String dateTimeLabel;
  final double amount;
  final DonationType type;
}

final List<DonationTransaction> _demoTransactions = [
  DonationTransaction(
    title: 'Shri Ram Prasad - Monthly Donation',
    dateTimeLabel: '12 Feb, 10:30 AM',
    amount: 5000,
    type: DonationType.credit,
  ),
  DonationTransaction(
    title: 'Community Hall Cleaning Expense',
    dateTimeLabel: '10 Feb, 05:15 PM',
    amount: 1800,
    type: DonationType.debit,
  ),
  DonationTransaction(
    title: 'Smt. Sunita Devi - Festival Fund',
    dateTimeLabel: '08 Feb, 02:10 PM',
    amount: 2500,
    type: DonationType.credit,
  ),
  DonationTransaction(
    title: 'Scholarship Distribution',
    dateTimeLabel: '05 Feb, 11:00 AM',
    amount: 7000,
    type: DonationType.debit,
  ),
  DonationTransaction(
    title: 'Shri Anand Kumar - Special Donation',
    dateTimeLabel: '02 Feb, 06:45 PM',
    amount: 10000,
    type: DonationType.credit,
  ),
];
