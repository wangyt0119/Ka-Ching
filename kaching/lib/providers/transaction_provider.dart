import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  Map<String, double> _balances = {};

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, double> get balances => _balances;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _transactionService.getAllTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _transactionService.getUserTransactions(userId);
      _transactions.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
      
      // Calculate balances
      _balances = await _transactionService.calculateBalances(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get transactions for a specific activity
  List<Transaction> getActivityTransactions(String activityId) {
    return _transactions.where((t) => t.activityId == activityId).toList();
  }

  // Calculate balances for a specific activity
  Map<String, double> getActivityBalances(String activityId) {
    final activityTransactions = getActivityTransactions(activityId);
    Map<String, double> activityBalances = {};
    
    for (final transaction in activityTransactions) {
      if (transaction.type == TransactionType.expense) {
        // Add amount to payer's balance
        activityBalances[transaction.payerId] = (activityBalances[transaction.payerId] ?? 0) + transaction.amount;
        
        // Subtract each participant's share
        for (final entry in transaction.participants.entries) {
          activityBalances[entry.key] = (activityBalances[entry.key] ?? 0) - entry.value;
        }
      } else if (transaction.type == TransactionType.payment) {
        // Add payment to receiver's balance
        for (final entry in transaction.participants.entries) {
          activityBalances[entry.key] = (activityBalances[entry.key] ?? 0) + entry.value;
          activityBalances[transaction.payerId] = (activityBalances[transaction.payerId] ?? 0) - entry.value;
        }
      }
    }
    
    return activityBalances;
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _transactionService.addTransaction(transaction);
      await loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> settleUp(String payerId, String receiverId, double amount, {String? activityId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final settlement = Transaction(
        title: 'Settlement',
        amount: amount,
        date: DateTime.now(),
        payerId: payerId,
        participants: {receiverId: amount},
        type: TransactionType.payment,
        activityId: activityId,
      );
      
      await _transactionService.addTransaction(settlement);
      await loadUserTransactions(payerId);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 