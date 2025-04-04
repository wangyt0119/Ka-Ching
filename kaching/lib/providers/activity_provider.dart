import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService = ActivityService();
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _activityService.getAllActivities();
      _activities.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by date, newest first
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserActivities(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _activityService.getUserActivities(userId);
      _activities.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by date, newest first
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addActivity(Activity activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _activityService.addActivity(activity);
      await loadActivities();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 