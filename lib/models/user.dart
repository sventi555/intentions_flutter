import 'package:intentions_flutter/utils/json.dart';

class User {
  final String id;
  final String email;
  final String username;
  final bool isPrivate;
  final String? image;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.isPrivate,
    this.image,
  });

  factory User.fromJson(String id, Json json) {
    return User(
      id: id,
      email: json['email'],
      username: json['username'],
      isPrivate: json['private'],
      image: json['image'],
    );
  }
}
