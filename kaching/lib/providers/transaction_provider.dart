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

  Future<bool> settleUp(String payerId, String receiverId, double amount) async {
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
        type: TransactionType.settlement,
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