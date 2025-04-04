import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'add_friend_screen.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({Key? key}) : super(key: key);

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadFriends(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Filter friends by name
    final filteredFriends = userProvider.friends.where((friend) {
      return friend.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFriends,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredFriends.isEmpty
                      ? const Center(
                          child: Text(
                            'No friends found',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredFriends.length,
                          itemBuilder: (context, index) {
                            final friend = filteredFriends[index];
                            final balance = transactionProvider.balances[friend.id] ?? 0;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  friend.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                ),
                              ),
                              title: Text(friend.name),
                              subtitle: Text(friend.email),
                              trailing: balance != 0
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${balance.abs().toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: balance > 0
                                                ? AppTheme.positiveAmount
                                                : AppTheme.negativeAmount,
                                          ),
                                        ),
                                        Text(
                                          balance > 0 ? 'they owe you' : 'you owe',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'settled up',
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddFriendScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.person_add, color: AppTheme.textPrimary),
      ),
    );
  }
}
