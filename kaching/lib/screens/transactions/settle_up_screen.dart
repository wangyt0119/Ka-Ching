import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({Key? key}) : super(key: key);

  @override
  _SettleUpScreenState createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  String? _selectedUserId;
  final _amountController = TextEditingController();
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _settleUp() async {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a friend to settle up with')),
      );
      return;
    }
    
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    final success = await transactionProvider.settleUp(
      authProvider.currentUser!.id,
      _selectedUserId!,
      amount,
    );
    
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Filter balances to only show negative balances (what you owe)
    final debts = transactionProvider.balances.entries
        .where((entry) => entry.value < 0)
        .toList();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settle Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a friend to settle up with',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (debts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'You don\'t owe anyone money',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  final entry = debts[index];
                  return FutureBuilder<dynamic>(
                    future: userProvider.getUserById(entry.key),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      final user = snapshot.data;
                      
                      return RadioListTile<String>(
                        title: Text(user?.name ?? 'Unknown'),
                        subtitle: Text('You owe \$${entry.value.abs().toStringAsFixed(2)}'),
                        value: entry.key,
                        groupValue: _selectedUserId,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                            _amountController.text = entry.value.abs().toStringAsFixed(2);
                          });
                        },
                        activeColor: AppTheme.accentColor,
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 24),
            const Text(
              'Enter amount to settle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _settleUp,
                child: const Text('Settle Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 