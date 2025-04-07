import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class CurrencyService {
  static const String _selectedCurrencyKey = 'selected_currency';
  
  // Common currencies with their exchange rates
  static final List<Currency> _currencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', exchangeRate: 1.0),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', exchangeRate: 0.85),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', exchangeRate: 0.73),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', exchangeRate: 110.33),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', exchangeRate: 6.47),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', exchangeRate: 74.38),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', exchangeRate: 4.20),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', exchangeRate: 1.35),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', exchangeRate: 14200),
  ];

  // Get all available currencies
  List<Currency> getAllCurrencies() {
    return _currencies;
  }

  // Get currency by code
  Currency? getCurrencyByCode(String code) {
    try {
      return _currencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  // Get the default currency (USD)
  Currency getDefaultCurrency() {
    return _currencies.first;
  }

  // Save selected currency
  Future<void> setSelectedCurrency(Currency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCurrencyKey, currency.code);
  }

  // Get selected currency
  Future<Currency> getSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_selectedCurrencyKey);
    
    if (code != null) {
      final currency = getCurrencyByCode(code);
      if (currency != null) {
        return currency;
      }
    }
    
    return getDefaultCurrency();
  }
} 