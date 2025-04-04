import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String name;
  final List<String> memberIds;
  final String? description;
  final String? imageUrl;

  Group({
    String? id,
    required this.name,
    required this.memberIds,
    this.description,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      memberIds: List<String>.from(json['memberIds']),
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
} 