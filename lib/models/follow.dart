enum FollowStatus { pending, accepted }

class Follow {
  final FollowStatus status;
  final String fromUser;

  const Follow({required this.status, required this.fromUser});

  factory Follow.fromJson(String fromUserId, Map<String, dynamic> json) {
    return Follow(
      status: json['status'] == 'pending'
          ? FollowStatus.pending
          : FollowStatus.accepted,
      fromUser: fromUserId,
    );
  }
}
