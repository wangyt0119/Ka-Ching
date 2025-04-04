import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import '../../transactions/transaction_detail_screen.dart';

class RecentActivity extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentActivity({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionListItem(transaction: transaction);
      },
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = authProvider.currentUser?.id;
    
    final isExpense = transaction.type == TransactionType.expense;
    final isSettlement = transaction.type == TransactionType.settlement;
    
    final isPayer = transaction.payerId == currentUserId;
    final isParticipant = transaction.participants.containsKey(currentUserId);
    
    double amount = 0;
    String description = '';
    
    if (isExpense) {
      if (isPayer) {
        // Current user paid for the expense
        amount = transaction.participants.entries
            .where((e) => e.key != currentUserId)
            .fold(0, (sum, e) => sum + e.value);
        description = 'You paid';
      } else if (isParticipant) {
        // Current user is a participant
        amount = -(transaction.participants[currentUserId] ?? 0);
        description = 'You owe';
      }
    } else if (isSettlement) {
      if (isPayer) {
        // Current user paid the settlement
        amount = -transaction.amount;
        description = 'You paid';
      } else if (isParticipant) {
        // Current user received the settlement
        amount = transaction.amount;
        description = 'You received';
      }
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isExpense ? AppTheme.primaryColor : AppTheme.secondaryColor,
        child: Icon(
          isExpense ? Icons.receipt : Icons.swap_horiz,
          color: AppTheme.textPrimary,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        DateFormat('MMM d, yyyy').format(transaction.date),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amount >= 0 ? AppTheme.positiveAmount : AppTheme.negativeAmount,
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
    );
  }
} 