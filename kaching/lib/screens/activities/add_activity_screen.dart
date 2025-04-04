import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/activity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedFriendIds = {};
  
  @override
  void initState() {
    super.initState();
    _loadFriends();
    
    // Always include current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _selectedFriendIds.add(authProvider.currentUser!.id);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadFriends() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await userProvider.loadFriends(authProvider.currentUser!.id);
    }
  }
  
  Future<void> _createActivity() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFriendIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one member')),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) return;
      
      // Create new activity
      final activity = Activity(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        memberIds: _selectedFriendIds.toList(),
      );
      
      final success = await activityProvider.addActivity(activity);
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Create Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Activity Name',
                  hintText: 'e.g., Bali Trip, Dinner at Joe\'s',
                  prefixIcon: Icon(Icons.hiking),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an activity name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add some details about this activity',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Members
              const Text(
                'Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select friends to include in this activity',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Current User (always included)
              if (authProvider.currentUser != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accentColor,
                    child: Text(
                      authProvider.currentUser!.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: const Text('You'),
                  subtitle: Text(authProvider.currentUser!.email),
                  trailing: const Icon(
                    Icons.check_circle,
                    color: AppTheme.accentColor,
                  ),
                ),
              
              // Divider
              const Divider(height: 32),
              
              // Friends List
              const Text(
                'Friends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              if (userProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (userProvider.friends.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'You don\'t have any friends yet',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userProvider.friends.length,
                  itemBuilder: (context, index) {
                    final friend = userProvider.friends[index];
                    final isSelected = _selectedFriendIds.contains(friend.id);
                    
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedFriendIds.add(friend.id);
                          } else {
                            _selectedFriendIds.remove(friend.id);
                          }
                        });
                      },
                      title: Text(friend.name),
                      subtitle: Text(friend.email),
                      secondary: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          friend.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      activeColor: AppTheme.primaryColor,
                    );
                  },
                ),
              
              const SizedBox(height: 32),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: activityProvider.isLoading ? null : _createActivity,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: activityProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('CREATE ACTIVITY'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 