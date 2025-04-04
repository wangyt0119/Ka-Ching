import '../models/user.dart';

class UserService {
  // Mock users
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
    User(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike@example.com',
      phoneNumber: '555-123-4567',
    ),
    User(
      id: '4',
      name: 'Sarah Williams',
      email: 'sarah@example.com',
      phoneNumber: '444-555-6666',
    ),
  ];

  // Get all users
  Future<List<User>> getAllUsers() async {
    // In a real app, this would fetch from a backend
    return _users;
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get user's friends (mock implementation)
  Future<List<User>> getUserFriends(String userId) async {
    // In a real app, this would fetch the user's friends from a backend
    // For now, we'll return all users except the current user
    return _users.where((user) => user.id != userId).toList();
  }

  // Add friend (mock implementation)
  Future<bool> addFriend(String userId, String friendId) async {
    // In a real app, this would create a friendship in the backend
    return true;
  }
} 