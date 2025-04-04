import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: transaction.type == TransactionType.expense
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                          child: Icon(
                            transaction.type == TransactionType.expense
                                ? Icons.receipt
                                : Icons.swap_horiz,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                DateFormat('MMMM d, yyyy').format(transaction.date),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.notes!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paid by',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<dynamic>(
              future: userProvider.getUserById(transaction.payerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                final payer = snapshot.data;
                final isCurrentUserPayer = transaction.payerId == currentUserId;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accentColor,
                    child: Text(
                      payer?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  title: Text(isCurrentUserPayer ? 'You' : (payer?.name ?? 'Unknown')),
                  trailing: Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Participants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...transaction.participants.entries.map((entry) {
              return FutureBuilder<dynamic>(
                future: userProvider.getUserById(entry.key),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  final participant = snapshot.data;
                  final isCurrentUser = entry.key == currentUserId;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentUser ? AppTheme.accentColor : AppTheme.primaryColor,
                      child: Text(
                        participant?.name.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    title: Text(isCurrentUser ? 'You' : (participant?.name ?? 'Unknown')),
                    trailing: Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            if (transaction.receiptImagePath != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Receipt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(transaction.receiptImagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 