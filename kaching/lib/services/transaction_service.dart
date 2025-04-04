import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionService {
  static const String _transactionsKey = 'transactions';
  
  // Mock transactions
  static final List<Transaction> _mockTransactions = [
    Transaction(
      id: '1',
      title: 'Dinner',
      amount: 100.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      payerId: '1',
      participants: {'1': 50.0, '2': 50.0},
      type: TransactionType.expense,
    ),
    Transaction(
      id: '2',
      title: 'Movie tickets',
      amount: 30.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      payerId: '2',
      participants: {'1': 15.0, '2': 15.0},
      type: TransactionType.expense,
    ),
    Transaction(
      id: '3',
      title: 'Settlement',
      amount: 65.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      payerId: '1',
      participants: {'2': 65.0},
      type: TransactionType.settlement,
    ),
  ];

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList(_transactionsKey);
    
    if (transactionsJson == null || transactionsJson.isEmpty) {
      // Initialize with mock data
      await _saveMockTransactions();
      return _mockTransactions;
    }
    
    return transactionsJson
        .map((json) => Transaction.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save mock transactions
  Future<void> _saveMockTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = _mockTransactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();
    
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  // Add a transaction
  Future<Transaction> addTransaction(Transaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getAllTransactions();
    
    transactions.add(transaction);
    
    final transactionsJson = transactions
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    
    await prefs.setStringList(_transactionsKey, transactionsJson);
    
    return transaction;
  }

  // Get transactions for a specific user
  Future<List<Transaction>> getUserTransactions(String userId) async {
    final transactions = await getAllTransactions();
    
    return transactions.where((t) => 
      t.payerId == userId || t.participants.containsKey(userId)
    ).toList();
  }

  // Get transactions for a specific group
  Future<List<Transaction>> getGroupTransactions(String groupId) async {
    final transactions = await getAllTransactions();
    
    return transactions.where((t) => t.groupId == groupId).toList();
  }

  // Calculate balances between users
  Future<Map<String, double>> calculateBalances(String userId) async {
    final transactions = await getAllTransactions();
    final Map<String, double> balances = {};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        // If user paid for the expense
        if (transaction.payerId == userId) {
          for (final entry in transaction.participants.entries) {
            if (entry.key != userId) {
              balances[entry.key] = (balances[entry.key] ?? 0) + entry.value;
            }
          }
        } 
        // If user is a participant
        else if (transaction.participants.containsKey(userId)) {
          final amount = transaction.participants[userId] ?? 0;
          balances[transaction.payerId] = (balances[transaction.payerId] ?? 0) - amount;
        }
      } 
      // Handle settlements
      else if (transaction.type == TransactionType.settlement) {
        if (transaction.payerId == userId) {
          for (final entry in transaction.participants.entries) {
            balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
          }
        } else if (transaction.participants.containsKey(userId)) {
          final amount = transaction.participants[userId] ?? 0;
          balances[transaction.payerId] = (balances[transaction.payerId] ?? 0) + amount;
        }
      }
    }
    
    return balances;
  }
} 