import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import '../../transactions/settle_up_screen.dart';

class BalanceSummary extends StatelessWidget {
  const BalanceSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    if (authProvider.currentUser == null) {
      return const SizedBox.shrink();
    }

    double totalOwed = 0;
    double totalOwe = 0;

    for (final entry in transactionProvider.balances.entries) {
      final amount = entry.value;
      if (amount > 0) {
        totalOwed += amount;
      } else if (amount < 0) {
        totalOwe += amount.abs();
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceItem(
                    title: 'You owe',
                    amount: totalOwe,
                    isPositive: false,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: AppTheme.dividerColor,
                ),
                Expanded(
                  child: _BalanceItem(
                    title: 'You are owed',
                    amount: totalOwed,
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total balance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '\$${(totalOwed - totalOwe).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: totalOwed - totalOwe >= 0
                        ? AppTheme.positiveAmount
                        : AppTheme.negativeAmount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (totalOwe > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettleUpScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Settle Up'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String title;
  final double amount;
  final bool isPositive;

  const _BalanceItem({
    Key? key,
    required this.title,
    required this.amount,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPositive ? AppTheme.positiveAmount : AppTheme.negativeAmount,
          ),
        ),
      ],
    );
  }
} 