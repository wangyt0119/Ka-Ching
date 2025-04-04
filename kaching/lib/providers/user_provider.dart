import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _users = [];
  List<User> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<User> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFriends(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _friends = await _userService.getUserFriends(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFriend(String userId, String friendId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userService.addFriend(userId, friendId);
      if (success) {
        await loadFriends(userId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      return await _userService.getUserById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}