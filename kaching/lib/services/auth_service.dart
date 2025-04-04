import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Mock user data
  static final List<User> _users = [
    User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '123-456-7890',
    ),
    User(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phoneNumber: '987-654-3210',
    ),
  ];

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData == null) return null;
    
    return User.fromJson(Map<String, dynamic>.from(
      Map<String, dynamic>.from({
        'id': prefs.getString('user_id') ?? '',
        'name': prefs.getString('user_name') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'profileImage': prefs.getString('user_profile_image'),
        'phoneNumber': prefs.getString('user_phone'),
      })
    ));
  }

  // Login
  Future<User?> login(String email, String password) async {
    // Mock login - in a real app, you would validate against a backend
    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Invalid credentials'),
    );
    
    // Save user data
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isLoggedInKey, true);
    prefs.setString('user_id', user.id);
    prefs.setString('user_name', user.name);
    prefs.setString('user_email', user.email);
    if (user.phoneNumber != null) {
      prefs.setString('user_phone', user.phoneNumber!);
    }
    if (user.profileImage != null) {
      prefs.setString('user_profile_image', user.profileImage!);
    }
    
    return user;
  }

  // Register
  Future<User> register(String name, String email, String password) async {
    // Mock registration - in a real app, you would send this to a backend
    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
    );
    
    _users.add(newUser);
    
    // Save user data
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isLoggedInKey, true);
    prefs.setString('user_id', newUser.id);
    prefs.setString('user_name', newUser.name);
    prefs.setString('user_email', newUser.email);
    
    return newUser;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isLoggedInKey, false);
    prefs.remove('user_id');
    prefs.remove('user_name');
    prefs.remove('user_email');
    prefs.remove('user_phone');
    prefs.remove('user_profile_image');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Update user profile
  Future<User> updateProfile(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update in mock data
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
    }
    
    // Update in shared preferences
    prefs.setString('user_name', updatedUser.name);
    prefs.setString('user_email', updatedUser.email);
    if (updatedUser.phoneNumber != null) {
      prefs.setString('user_phone', updatedUser.phoneNumber!);
    }
    if (updatedUser.profileImage != null) {
      prefs.setString('user_profile_image', updatedUser.profileImage!);
    }
    
    return updatedUser;
  }
} 