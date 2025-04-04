import 'package:uuid/uuid.dart';

class Activity {
  final String id;
  final String name;
  final String? description;
  final List<String> memberIds;
  final DateTime createdAt;
  final String? imageUrl;
  double totalAmount;

  Activity({
    String? id,
    required this.name,
    this.description,
    required this.memberIds,
    DateTime? createdAt,
    this.imageUrl,
    this.totalAmount = 0.0,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'totalAmount': totalAmount,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memberIds: List<String>.from(json['memberIds']),
      createdAt: DateTime.parse(json['createdAt']),
      imageUrl: json['imageUrl'],
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
    );
  }
} 