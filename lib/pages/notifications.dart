import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/follows.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authUserProvider).user?.uid;
    final List<Follow> follows =
        ref.watch(followsToUserProvider(userId)).value ?? [];

    final respondToFollow = ref.read(respondToFollowProvider);

    return Scaffold(
      body: ListView(
        children: [
          for (final follow in follows)
            ListTile(
              title: Text(
                follow.status == FollowStatus.pending
                    ? "${follow.fromUser.username} requested to follow you"
                    : '${follow.fromUser.username} followed you',
              ),
              leading: ProfilePic(image: follow.fromUser.image),
              trailing: follow.status == FollowStatus.pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            respondToFollow(RespondAction.accept);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            respondToFollow(RespondAction.decline);
                          },
                        ),
                      ],
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}
