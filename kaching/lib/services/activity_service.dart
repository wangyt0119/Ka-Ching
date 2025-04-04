import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

class ActivityService {
  static const String _activitiesKey = 'activities';
  
  // Mock activities
  static final List<Activity> _mockActivities = [
    Activity(
      id: '1',
      name: 'Batam Trip',
      description: 'Weekend getaway to Batam',
      memberIds: ['1', '2', '3'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      totalAmount: 450.0,
    ),
    Activity(
      id: '2',
      name: 'Johor Trip',
      description: 'Day trip to Johor Bahru',
      memberIds: ['1', '2', '4'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      totalAmount: 320.0,
    ),
    Activity(
      id: '3',
      name: 'Dinner at Marina Bay',
      description: 'Dinner with friends',
      memberIds: ['1', '3', '4'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      totalAmount: 180.0,
    ),
  ];

  // Get all activities
  Future<List<Activity>> getAllActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getStringList(_activitiesKey);
    
    if (activitiesJson == null || activitiesJson.isEmpty) {
      // Initialize with mock data
      await _saveMockActivities();
      return _mockActivities;
    }
    
    return activitiesJson
        .map((json) => Activity.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save mock activities
  Future<void> _saveMockActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = _mockActivities
        .map((activity) => jsonEncode(activity.toJson()))
        .toList();
    
    await prefs.setStringList(_activitiesKey, activitiesJson);
  }

  // Add an activity
  Future<Activity> addActivity(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getAllActivities();
    
    activities.add(activity);
    
    final activitiesJson = activities
        .map((a) => jsonEncode(a.toJson()))
        .toList();
    
    await prefs.setStringList(_activitiesKey, activitiesJson);
    
    return activity;
  }

  // Get activities for a specific user
  Future<List<Activity>> getUserActivities(String userId) async {
    final activities = await getAllActivities();
    
    return activities.where((a) => a.memberIds.contains(userId)).toList();
  }

  // Get activity by ID
  Future<Activity?> getActivityById(String id) async {
    final activities = await getAllActivities();
    
    try {
      return activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
} 