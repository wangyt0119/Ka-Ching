import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/activity_service.dart';
import '../../theme/app_theme.dart';
import '../transactions/add_expense_screen.dart';
import '../transactions/transaction_detail_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({
    Key? key,
    required this.activityId,
  }) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final ActivityService _activityService = ActivityService();
  Activity? _activity;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  Map<String, double> _memberBalances = {};

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load activity details
      final activity = await _activityService.getActivityById(widget.activityId);
      
      if (activity != null) {
        // Load transactions for this activity
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
        await transactionProvider.loadTransactions();
        
        // Filter transactions for this activity
        final activityTransactions = transactionProvider.transactions
            .where((t) => t.groupId == widget.activityId)
            .toList();
        
        // Calculate balances for each member
        final Map<String, double> balances = {};
        
        for (final transaction in activityTransactions) {
          if (transaction.type == TransactionType.expense) {
            // Add amount to payer's balance
            balances[transaction.payerId] = (balances[transaction.payerId] ?? 0) + transaction.amount;
            
            // Subtract each participant's share
            for (final entry in transaction.participants.entries) {
              balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
            }
          }
        }
        
        setState(() {
          _activity = activity;
          _transactions = activityTransactions;
          _memberBalances = balances;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading activity: ${e.toString()}')),
      );
    }
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = authProvider.currentUser?.id;
    
    return FutureBuilder<dynamic>(
      future: userProvider.getUserById(transaction.payerId),
      builder: (context, snapshot) {
        final payer = snapshot.data;
        final isCurrentUserPayer = transaction.payerId == currentUserId;
        
        // Calculate what the current user owes or is owed
        double userAmount = 0;
        if (isCurrentUserPayer) {
          // Current user paid, so they are owed money from others
          userAmount = transaction.amount - (transaction.participants[currentUserId] ?? 0);
        } else if (transaction.participants.containsKey(currentUserId)) {
          // Current user is a participant, so they owe money
          userAmount = -(transaction.participants[currentUserId] ?? 0);
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransactionDetailScreen(transaction: transaction),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Paid by ${isCurrentUserPayer ? 'you' : (payer?.name ?? 'Unknown')}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(transaction.date),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (userAmount != 0) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          userAmount > 0 
                              ? 'You are owed' 
                              : 'You owe',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${userAmount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: userAmount > 0 
                                ? AppTheme.positiveAmount 
                                : AppTheme.negativeAmount,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_activity?.name ?? 'Activity Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit activity functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit activity would be implemented here')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activity == null
              ? const Center(child: Text('Activity not found'))
              : RefreshIndicator(
                  onRefresh: _loadActivityData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Activity Header
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
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.hiking,
                                        color: AppTheme.primaryColor,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _activity!.name,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMMM d, yyyy').format(_activity!.createdAt),
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_activity!.description != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    _activity!.description!,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total spent',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\$${_activity!.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Member Balances
                        const Text(
                          'Member Balances',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _memberBalances.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final entry = _memberBalances.entries.elementAt(index);
                              final memberId = entry.key;
                              final balance = entry.value;
                              final isCurrentUser = memberId == currentUserId;
                              
                              return FutureBuilder<dynamic>(
                                future: userProvider.getUserById(memberId),
                                builder: (context, snapshot) {
                                  final user = snapshot.data;
                                  final name = isCurrentUser ? 'You' : (user?.name ?? 'Unknown');
                                  
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isCurrentUser 
                                          ? AppTheme.accentColor 
                                          : AppTheme.primaryColor,
                                      child: Text(
                                        (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(name),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${balance.abs().toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: balance > 0 
                                                ? AppTheme.positiveAmount 
                                                : balance < 0 
                                                    ? AppTheme.negativeAmount 
                                                    : AppTheme.settledColor,
                                          ),
                                        ),
                                        Text(
                                          balance > 0 
                                              ? 'gets back' 
                                              : balance < 0 
                                                  ? 'owes' 
                                                  : 'settled up',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddExpenseScreen(activityId: _activity!.id),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _transactions.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text(
                                    'No transactions yet',
                                    style: TextStyle(color: AppTheme.textSecondary),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = _transactions[index];
                                  return _buildTransactionItem(transaction);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(activityId: _activity?.id),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
} 