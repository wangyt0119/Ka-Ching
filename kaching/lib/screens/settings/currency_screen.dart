import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/currency.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_theme.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencies = currencyProvider.availableCurrencies;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: currencyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = currency.code == currencyProvider.selectedCurrency.code;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppTheme.primaryColor : AppTheme.secondaryColor.withOpacity(0.3),
                    child: Text(
                      currency.symbol,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(currency.name),
                  subtitle: Text(currency.code),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                  onTap: () async {
                    await currencyProvider.setSelectedCurrency(currency);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
    );
  }
} 