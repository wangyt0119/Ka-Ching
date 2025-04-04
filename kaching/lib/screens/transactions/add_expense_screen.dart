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
  final String? activityId;

  const AddExpenseScreen({Key? key, this.activityId}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  File? _receiptImage;
  Map<String, double> _participants = {};
  String? _selectedPayerId;
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
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadFriends() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await userProvider.loadFriends(authProvider.currentUser!.id);
      
      // Initialize current user as payer
      setState(() {
        _selectedPayerId = authProvider.currentUser!.id;
        _participants[authProvider.currentUser!.id] = 0;
      });
      
      _calculateShares();
    }
  }
  
  void _calculateShares() {
    if (_splitEqually && _participants.isNotEmpty) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final perPersonAmount = amount / _participants.length;
      
      setState(() {
        for (final key in _participants.keys) {
          _participants[key] = perPersonAmount;
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
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }
  
  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_participants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one participant')),
        );
        return;
      }
      
      if (_selectedPayerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select who paid')),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) return;
      
      // Create new transaction
      final transaction = Transaction(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        date: _date,
        payerId: _selectedPayerId!,
        participants: Map.from(_participants),
        receiptImagePath: _receiptImage?.path,
        type: TransactionType.expense,
        groupId: widget.activityId,
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
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
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
                  hintText: 'e.g., Dinner, Taxi, Hotel',
                  prefixIcon: Icon(Icons.title),
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
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                onChanged: (_) {
                  if (_splitEqually) {
                    _calculateShares();
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add some details about this expense',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickImage,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Receipt (optional)',
                    prefixIcon: Icon(Icons.receipt),
                  ),
                  child: _receiptImage == null
                      ? const Text('Tap to add a receipt image')
                      : Image.file(
                          _receiptImage!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Paid By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (userProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userProvider.friends.length + 1,
                  itemBuilder: (context, index) {
                    User user;
                    bool isCurrentUser = false;
                    
                    if (index == 0) {
                      user = authProvider.currentUser!;
                      isCurrentUser = true;
                    } else {
                      user = userProvider.friends[index - 1];
                    }
                    
                    return RadioListTile<String>(
                      title: Text(isCurrentUser ? 'You' : user.name),
                      value: user.id,
                      groupValue: _selectedPayerId,
                      onChanged: (value) {
                        setState(() {
                          _selectedPayerId = value;
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Split',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  ChoiceChip(
                    label: const Text('Equally'),
                    selected: _splitEqually,
                    onSelected: (selected) {
                      setState(() {
                        _splitEqually = selected;
                        if (selected) {
                          _calculateShares();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Unequally'),
                    selected: !_splitEqually,
                    onSelected: (selected) {
                      setState(() {
                        _splitEqually = !selected;
                        if (!selected) {
                          _calculateShares();
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (userProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userProvider.friends.length + 1,
                  itemBuilder: (context, index) {
                    User user;
                    bool isCurrentUser = false;
                    
                    if (index == 0) {
                      user = authProvider.currentUser!;
                      isCurrentUser = true;
                    } else {
                      user = userProvider.friends[index - 1];
                    }
                    
                    final isParticipant = _participants.containsKey(user.id);
                    
                    return _buildParticipantTile(user, isCurrentUser, isParticipant);
                  },
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: transactionProvider.isLoading ? null : _addExpense,
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
                      : const Text('ADD EXPENSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildParticipantTile(User user, bool isCurrentUser, bool isSelected) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _participants[user.id] = 0;
            _calculateShares();
          } else {
            _participants.remove(user.id);
            _calculateShares();
          }
        });
      },
      title: Text(isCurrentUser ? 'You' : user.name),
      subtitle: isSelected && !_splitEqually
          ? TextFormField(
              initialValue: (_participants[user.id] ?? 0).toString(),
              decoration: const InputDecoration(
                prefixText: '\$',
                isDense: true,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                setState(() {
                  _participants[user.id] = double.tryParse(value) ?? 0;
                });
              },
            )
          : null,
      secondary: CircleAvatar(
        backgroundColor: isCurrentUser ? AppTheme.accentColor : AppTheme.primaryColor,
        child: Text(
          user.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 