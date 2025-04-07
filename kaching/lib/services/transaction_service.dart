import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionService {
  static const String _transactionsKey = 'transactions';
  
  // Mock transactions with activity IDs
  static final List<Transaction> _mockTransactions = [
    // Activity 1: Batam Trip
    Transaction(
      id: '1',
      title: 'Hotel Booking',
      amount: 250.0,
      description: 'Two nights at Batam Resort',
      date: DateTime.now().subtract(const Duration(days: 12)),
      payerId: '1',
      participants: {'1': 125.0, '2': 125.0},
      type: TransactionType.expense,
      activityId: "1", // String ID matching activity
    ),
    Transaction(
      id: '2',
      title: 'Ferry Tickets',
      amount: 120.0,
      description: 'Return ferry tickets',
      date: DateTime.now().subtract(const Duration(days: 11)),
      payerId: '2',
      participants: {'1': 60.0, '2': 60.0},
      type: TransactionType.expense,
      activityId: "1", // String ID matching activity
    ),
    Transaction(
      id: '3',
      title: 'Seafood Dinner',
      amount: 80.0,
      description: 'Dinner at Golden Prawn Restaurant',
      date: DateTime.now().subtract(const Duration(days: 10)),
      payerId: '1',
      participants: {'1': 40.0, '2': 40.0},
      type: TransactionType.expense,
      activityId: "1", // String ID matching activity
    ),
    Transaction(
      id: '4',
      title: 'Taxi Rides',
      amount: 45.0,
      description: 'All taxi trips during stay',
      date: DateTime.now().subtract(const Duration(days: 10)),
      payerId: '3',
      participants: {'1': 15.0, '2': 15.0, '3': 15.0},
      type: TransactionType.expense,
      activityId: "1", // String ID matching activity
    ),
    Transaction(
      id: '5',
      title: 'Snacks & Drinks',
      amount: 30.0,
      date: DateTime.now().subtract(const Duration(days: 9)),
      payerId: '2',
      participants: {'1': 10.0, '2': 10.0, '3': 10.0},
      type: TransactionType.expense,
      activityId: "1", // String ID matching activity
    ),
    
    // Activity 2: Johor Trip
    Transaction(
      id: '6',
      title: 'Bus Tickets',
      amount: 75.0,
      description: 'Return bus tickets to Johor',
      date: DateTime.now().subtract(const Duration(days: 5)),
      payerId: '1',
      participants: {'1': 25.0, '2': 25.0, '4': 25.0},
      type: TransactionType.expense,
      activityId: "2", // String ID matching activity
    ),
    Transaction(
      id: '7',
      title: 'Lunch',
      amount: 60.0,
      description: 'Lunch at JB food court',
      date: DateTime.now().subtract(const Duration(days: 4)),
      payerId: '4',
      participants: {'1': 20.0, '2': 20.0, '4': 20.0},
      type: TransactionType.expense,
      activityId: "2", // String ID matching activity
    ),
    Transaction(
      id: '8',
      title: 'Shopping',
      amount: 150.0,
      description: 'Group souvenirs and gifts',
      date: DateTime.now().subtract(const Duration(days: 4)),
      payerId: '2',
      participants: {'1': 50.0, '2': 50.0, '4': 50.0},
      type: TransactionType.expense,
      activityId: "2", // String ID matching activity
    ),
    Transaction(
      id: '9',
      title: 'Dinner',
      amount: 90.0,
      description: 'Farewell dinner',
      date: DateTime.now().subtract(const Duration(days: 4)),
      payerId: '1',
      participants: {'1': 30.0, '2': 30.0, '4': 30.0},
      type: TransactionType.expense,
      activityId: "2", // String ID matching activity
    ),
    
    // Activity 3: Dinner at Marina Bay
    Transaction(
      id: '10',
      title: 'Restaurant Bill',
      amount: 180.0, 
      description: 'Dinner at Marina Bay restaurant',
      date: DateTime.now().subtract(const Duration(days: 2)),
      payerId: '3',
      participants: {'1': 60.0, '3': 60.0, '4': 60.0},
      type: TransactionType.expense,
      activityId: "3", // String ID matching activity
    ),
    Transaction(
      id: '11',
      title: 'Drinks',
      amount: 45.0,
      description: 'Cocktails after dinner',
      date: DateTime.now().subtract(const Duration(days: 2)),
      payerId: '1',
      participants: {'1': 15.0, '3': 15.0, '4': 15.0},
      type: TransactionType.expense,
      activityId: "3", // String ID matching activity
    ),
    
    // Settlements
    Transaction(
      id: '12',
      title: 'Settlement',
      amount: 120.0,
      description: 'Settling Batam trip expenses',
      date: DateTime.now().subtract(const Duration(days: 8)),
      payerId: '2',
      participants: {'1': 120.0},
      type: TransactionType.payment,
      activityId: "1", // String ID matching activity
    ),
    Transaction(
      id: '13',
      title: 'Settlement',
      amount: 65.0,
      description: 'Partial settlement for Johor',
      date: DateTime.now().subtract(const Duration(days: 3)),
      payerId: '4',
      participants: {'1': 65.0},
      type: TransactionType.payment,
      activityId: "2", // String ID matching activity
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
    
    return transactions.where((t) => t.activityId.toString() == groupId.toString()).toList();
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
      // Handle payments
      else if (transaction.type == TransactionType.payment) {
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

  // Add this method
  Future<void> resetMockData() async {
    await _saveMockTransactions();
  }
} 