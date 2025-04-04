import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Not logged in'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.accentColor,
                child: user.profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.file(
                          File(user.profileImage!),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: AppTheme.textPrimary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                user.phoneNumber!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings would be implemented here')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                // Navigate to help screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support would be implemented here')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 