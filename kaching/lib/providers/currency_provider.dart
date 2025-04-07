import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();
  Currency _selectedCurrency;
  bool _isLoading = false;

  CurrencyProvider() : _selectedCurrency = CurrencyService().getDefaultCurrency() {
    _initCurrency();
  }

  Currency get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  List<Currency> get availableCurrencies => _currencyService.getAllCurrencies();

  Future<void> _initCurrency() async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedCurrency = await _currencyService.getSelectedCurrency();
    } catch (e) {
      // If there's an error, fallback to default
      _selectedCurrency = _currencyService.getDefaultCurrency();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedCurrency(Currency currency) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _currencyService.setSelectedCurrency(currency);
      _selectedCurrency = currency;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Format an amount according to the selected currency
  String formatAmount(double amount) {
    return '${_selectedCurrency.symbol}${amount.toStringAsFixed(2)}';
  }

  // Convert an amount from one currency to the selected currency
  double convertToSelectedCurrency(double amount, Currency fromCurrency) {
    return Currency.convert(amount, fromCurrency, _selectedCurrency);
  }
} 