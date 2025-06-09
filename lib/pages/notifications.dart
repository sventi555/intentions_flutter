import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/follows.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

final routerProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).user;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Notifications(),
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/signin',
        redirect: (context, state) {
          if (user != null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) => SignIn(),
      ),
      GoRoute(
        path: '/signup',
        redirect: (context, state) {
          if (user != null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) => SignUp(),
      ),
    ],
  );
});

class NotificationsTab extends ConsumerWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authUserProvider);
    final router = ref.watch(routerProvider);

    if (userState.loading) {
      return CircularProgressIndicator();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authUserProvider).user?.uid;

    if (userId == null) {
      throw StateError('user should be signed in to view notifications');
    }

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
