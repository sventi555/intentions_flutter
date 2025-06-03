class Intention {
  final String userId;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int postCount;

  const Intention({
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.postCount,
  });

  factory Intention.fromJson(Map<String, dynamic> json) {
    return Intention(
      userId: json['userId'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      postCount: json['postCount'],
    );
  }
}
