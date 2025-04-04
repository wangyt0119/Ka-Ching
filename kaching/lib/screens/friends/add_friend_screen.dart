import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUsers();
  }
  
  Future<void> _addFriend(String friendId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    final success = await userProvider.addFriend(
      authProvider.currentUser!.id,
      friendId,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully')),
      );
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Filter users to exclude current user and existing friends
    final filteredUsers = userProvider.users.where((user) {
      // Exclude current user
      if (user.id == authProvider.currentUser?.id) return false;
      
      // Exclude existing friends
      if (userProvider.friends.any((friend) => friend.id == user.id)) return false;
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
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
                : filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: AppTheme.textPrimary),
                              ),
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add),
                              color: AppTheme.accentColor,
                              onPressed: () => _addFriend(user.id),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 