import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  File? _receiptImage;
  final Map<String, double> _participants = {};
  bool _splitEqually = true;
  
  @override
  void initState() {
    super.initState();
    _loadFriends();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadFriends() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await userProvider.loadFriends(authProvider.currentUser!.id);
      
      // Initialize participants with current user and friends
      setState(() {
        _participants[authProvider.currentUser!.id] = 0;
        for (final friend in userProvider.friends) {
          _participants[friend.id] = 0;
        }
      });
    }
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }
  
  void _calculateShares() {
    if (!_splitEqually) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    final participantCount = _participants.keys.length;
    
    if (participantCount > 0) {
      final share = amount / participantCount;
      
      setState(() {
        for (final key in _participants.keys) {
          _participants[key] = share;
        }
      });
    }
  }
  
  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) return;
      
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();
      
      final transaction = Transaction(
        title: title,
        amount: amount,
        date: DateTime.now(),
        payerId: authProvider.currentUser!.id,
        participants: Map.from(_participants),
        type: TransactionType.expense,
        notes: notes.isNotEmpty ? notes : null,
        receiptImagePath: _receiptImage?.path,
      );
      
      final success = await transactionProvider.addTransaction(transaction);
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Dinner, Movie tickets',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
                onChanged: (_) => _calculateShares(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add any additional details',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Add Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  if (_receiptImage != null) ...[
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _receiptImage!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Split Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SwitchListTile(
                title: const Text('Split equally'),
                value: _splitEqually,
                onChanged: (value) {
                  setState(() {
                    _splitEqually = value;
                    if (_splitEqually) {
                      _calculateShares();
                    }
                  });
                },
                activeColor: AppTheme.accentColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (authProvider.currentUser != null)
                _buildParticipantTile(
                  authProvider.currentUser!,
                  isCurrentUser: true,
                ),
              ...userProvider.friends.map((friend) => _buildParticipantTile(friend)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildParticipantTile(User user, {bool isCurrentUser = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrentUser ? AppTheme.accentColor : AppTheme.primaryColor,
        child: Text(
          user.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      title: Text(user.name),
      subtitle: _splitEqually
          ? Text('Equal share: \$${(_participants[user.id] ?? 0).toStringAsFixed(2)}')
          : TextFormField(
              initialValue: (_participants[user.id] ?? 0).toString(),
              decoration: const InputDecoration(
                prefixText: '\$',
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                setState(() {
                  _participants[user.id] = double.tryParse(value) ?? 0;
                });
              },
            ),
      trailing: Checkbox(
        value: (_participants[user.id] ?? 0) > 0,
        activeColor: AppTheme.accentColor,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              // Include participant
              _participants[user.id] = 0;
              _calculateShares();
            } else {
              // Remove participant
              _participants[user.id] = 0;
              _calculateShares();
            }
          });
        },
      ),
    );
  }
} 