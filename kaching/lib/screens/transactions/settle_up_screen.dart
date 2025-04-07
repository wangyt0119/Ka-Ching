import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/activity_provider.dart';

class SettleUpScreen extends StatefulWidget {
  final String? activityId;

  const SettleUpScreen({Key? key, this.activityId}) : super(key: key);

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
      activityId: widget.activityId,
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
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    // Get balances for the current context (activity or global)
    Map<String, double> balances = widget.activityId != null 
        ? transactionProvider.getActivityBalances(widget.activityId!)
        : transactionProvider.balances;
    
    // Filter balances to only show negative balances (what you owe)
    final debts = balances.entries
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
            // Activity indicator if in an activity
            if (widget.activityId != null) ...[
              FutureBuilder<dynamic>(
                future: Provider.of<ActivityProvider>(context, listen: false)
                    .getActivityById(widget.activityId!),
                builder: (context, snapshot) {
                  final activityName = snapshot.data?.name ?? 'Activity';
                  
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppTheme.primaryLightColor.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.hiking, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Settling up in: $activityName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            
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
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: AppTheme.positiveAmount,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'You don\'t owe anyone money',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All settled up! Add more expenses to start tracking debts.',
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final user = snapshot.data;
                      
                      return RadioListTile<String>(
                        title: Text(user?.name ?? 'Unknown'),
                        subtitle: Text(
                          'You owe ${currencyProvider.formatAmount(entry.value.abs())}',
                          style: const TextStyle(
                            color: AppTheme.negativeAmount,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: entry.key,
                        groupValue: _selectedUserId,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                            _amountController.text = entry.value.abs().toStringAsFixed(2);
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                        secondary: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
            const SizedBox(height: 32),
            const Text(
              'Enter amount to settle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount with Currency
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: currencyProvider.selectedCurrency.code,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.currency_exchange),
                    color: AppTheme.primaryColor,
                    onPressed: () {
                      Navigator.pushNamed(context, '/currency');
                    },
                    tooltip: 'Change Currency',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: transactionProvider.isLoading ? null : _settleUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: transactionProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('SETTLE UP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 