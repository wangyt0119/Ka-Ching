import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../home/widgets/recent_activity.dart';
import 'add_expense_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.loadUserTransactions(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export functionality would be implemented here'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: transactionProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : transactionProvider.transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactionProvider.transactions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final transaction = transactionProvider.transactions[index];
                      return TransactionListItem(transaction: transaction);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: AppTheme.textPrimary),
      ),
    );
  }
} 