class User {
  final String email;
  final String username;
  final String isPrivate;
  final String? image;

  const User({
    required this.email,
    required this.username,
    required this.isPrivate,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      isPrivate: json['private'],
      image: json['image'],
    );
  }
}
