import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../screens/settings/currency_screen.dart';

class BalanceSummaryWidget extends StatelessWidget {
  final String? userId;
  final String? activityId;
  final bool showSettleUp;
  
  const BalanceSummaryWidget({
    Key? key, 
    this.userId, 
    this.activityId,
    this.showSettleUp = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    // Get balances - either for a specific activity or overall
    Map<String, double> balances = activityId != null 
        ? transactionProvider.getActivityBalances(activityId!) 
        : transactionProvider.balances;
    
    double totalOwed = 0;
    double totalOwe = 0;

    for (final entry in balances.entries) {
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                // Currency Button
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CurrencyScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.currency_exchange, size: 16),
                  label: Text(currencyProvider.selectedCurrency.code),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primaryLightColor.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
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
                  currencyProvider.formatAmount(
                    currencyProvider.convertAmount(totalOwed - totalOwe)
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: totalOwed - totalOwe >= 0
                        ? AppTheme.positiveAmount
                        : AppTheme.negativeAmount,
                  ),
                ),
              ],
            ),
            if (showSettleUp && totalOwe > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to settle up screen
                    Navigator.of(context).pushNamed('/settle-up', arguments: activityId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Settle Up'),
                ),
              ),
            ],
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
    required this.title,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
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
          currencyProvider.formatAmount(
            currencyProvider.convertAmount(amount)
          ),
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