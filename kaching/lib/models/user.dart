class User {
  final String id;
  final String name;
  final String email;
  String? profileImage;
  String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
    );
  }
} 