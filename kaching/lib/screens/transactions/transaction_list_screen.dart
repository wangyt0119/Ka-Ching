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

DateTimeRange? _selectedDateRange;

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Filter transactions by title or description (case-insensitive)
    final filteredTransactions = transactionProvider.transactions.where((transaction) {
    final query = _searchQuery.toLowerCase();
    final title = transaction.title?.toLowerCase() ?? '';
    final description = transaction.description?.toLowerCase() ?? '';
    final matchesText = title.contains(query) || description.contains(query);

    final matchesDate = _selectedDateRange == null ||
        (transaction.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
        transaction.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

    return matchesText && matchesDate;
  }).toList();



    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
        if (_selectedDateRange != null)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Date Filter',
            onPressed: () {
              setState(() {
                _selectedDateRange = null;
              });
            },
          ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime now = DateTime.now();
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 5),
              initialDateRange: _selectedDateRange,
            );
            if (picked != null) {
              setState(() {
                _selectedDateRange = picked;
              });
            }
          },
        ),
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
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by title or description',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Showing from ${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} '
                'to ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          Expanded(

              child: transactionProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 70), // <- Added bottom padding
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return TransactionListItem(transaction: transaction);
                          },
                        ),
            ),
          ],
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
