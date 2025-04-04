import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../transactions/add_expense_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../friends/friend_list_screen.dart';
import '../profile/profile_screen.dart';
import '../activities/activity_detail_screen.dart';
import '../activities/add_activity_screen.dart';
import 'widgets/balance_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      
      await transactionProvider.loadUserTransactions(authProvider.currentUser!.id);
      await userProvider.loadFriends(authProvider.currentUser!.id);
      await activityProvider.loadUserActivities(authProvider.currentUser!.id);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const TransactionListScreen();
      case 2:
        return const FriendListScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    
    if (authProvider.currentUser == null) {
      return const Center(
        child: Text('Please login to continue'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authProvider.currentUser!.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const BalanceSummary(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddActivityScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activityProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (activityProvider.activities.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.hiking,
                      size: 64,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No activities yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first activity to start tracking expenses',
                      style: TextStyle(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddActivityScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Activity'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityProvider.activities.length,
                itemBuilder: (context, index) {
                  final activity = activityProvider.activities[index];
                  return _buildActivityCard(activity);
                },
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add an Expense'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(activity) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ActivityDetailScreen(activityId: activity.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hiking,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(activity.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${activity.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Text(
                        'Total spent',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${activity.memberIds.length} members',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View details',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('KaChing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications would be implemented here')),
              );
            },
          ),
        ],
      ),
      body: _getScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddActivityScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 