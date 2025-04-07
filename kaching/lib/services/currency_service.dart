import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class CurrencyService {
  static const String _selectedCurrencyKey = 'selected_currency';
  static const String _exchangeRatesKey = 'exchange_rates';
  static const String _lastUpdatedKey = 'exchange_rates_updated_at';
  
  // Common currencies with their initial rates
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

  // Map to store live exchange rates
  Map<String, double> _exchangeRates = {};
  
  // Initialize the service with latest rates
  Future<void> initialize() async {
    await _loadExchangeRates();
    await _updateExchangeRatesIfNeeded();
  }
  
  // Load saved exchange rates from local storage
  Future<void> _loadExchangeRates() async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = prefs.getString(_exchangeRatesKey);
    
    if (ratesJson != null) {
      final Map<String, dynamic> rates = jsonDecode(ratesJson);
      _exchangeRates = rates.map((key, value) => MapEntry(key, value.toDouble()));
      
      // Update currencies with saved rates
      for (var currency in _currencies) {
        if (_exchangeRates.containsKey(currency.code)) {
          currency.exchangeRate = _exchangeRates[currency.code]!;
        }
      }
    }
  }
  
  // Check if rates need updating (more than 12 hours old)
  Future<bool> _needsUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getString(_lastUpdatedKey);
    
    if (lastUpdated == null) return true;
    
    final lastUpdateTime = DateTime.parse(lastUpdated);
    final now = DateTime.now();
    
    return now.difference(lastUpdateTime).inHours > 12;
  }
  
  // Update exchange rates from external API
  Future<void> _updateExchangeRatesIfNeeded() async {
    if (await _needsUpdate()) {
      try {
        // Free exchange rate API
        // Note: In a production app, you would use a paid API with better reliability
        final response = await http.get(
          Uri.parse('https://open.er-api.com/v6/latest/USD')
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          if (data['rates'] != null) {
            final Map<String, dynamic> newRates = data['rates'];
            _exchangeRates = newRates.map((key, value) => MapEntry(key, value.toDouble()));
            
            // Update currency exchange rates
            for (var currency in _currencies) {
              if (_exchangeRates.containsKey(currency.code)) {
                currency.exchangeRate = _exchangeRates[currency.code]!;
              }
            }
            
            // Save to local storage
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_exchangeRatesKey, jsonEncode(_exchangeRates));
            await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
          }
        }
      } catch (e) {
        // If update fails, continue with existing rates
        print('Error updating exchange rates: $e');
      }
    }
  }

  // Get all available currencies with latest rates
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
  
  // Force update exchange rates (useful for refresh button)
  Future<bool> forceUpdateRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/USD')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['rates'] != null) {
          final Map<String, dynamic> newRates = data['rates'];
          _exchangeRates = newRates.map((key, value) => MapEntry(key, value.toDouble()));
          
          // Update currency exchange rates
          for (var currency in _currencies) {
            if (_exchangeRates.containsKey(currency.code)) {
              currency.exchangeRate = _exchangeRates[currency.code]!;
            }
          }
          
          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_exchangeRatesKey, jsonEncode(_exchangeRates));
          await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
          
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating exchange rates: $e');
      return false;
    }
  }
} 