class Intention {
  final String id;
  final String userId;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int postCount;

  const Intention({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.postCount,
  });

  factory Intention.fromJson(String id, Map<String, dynamic> json) {
    return Intention(
      id: id,
      userId: json['userId'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      postCount: json['postCount'],
    );
  }
}
