import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/currency_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/currency_screen.dart';
import 'screens/transactions/settle_up_screen.dart';
import 'theme/app_theme.dart';
import 'services/transaction_service.dart';
import 'services/activity_service.dart';
import 'services/currency_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services with mock data
  final transactionService = TransactionService();
  await transactionService.resetMockData();

  final activityService = ActivityService();
  await activityService.resetMockData();

  // Initialize currency service with real-time rates
  final currencyService = CurrencyService();
  await currencyService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Ka-Ching',
            theme: AppTheme.lightTheme,
            routes: {
              '/currency': (context) => const CurrencyScreen(),
              '/settle-up':
                  (context) => SettleUpScreen(
                    activityId:
                        ModalRoute.of(context)?.settings.arguments as String?,
                  ),
            },
            home:
                authProvider.isLoading
                    ? const SplashScreen()
                    : authProvider.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ka-Ching',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Split expenses with friends easily',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
