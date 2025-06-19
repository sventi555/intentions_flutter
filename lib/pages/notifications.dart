import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/follows.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

final notificationsRouterProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => Notifications(),
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;

          return Profile(userId: userId);
        },
      ),
      GoRoute(
        path: '/intention/:intentionId',
        builder: (context, state) {
          final intentionId = state.pathParameters['intentionId']!;

          return Intention(intentionId: intentionId);
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
    final user = ref.watch(authUserProvider);
    final router = ref.watch(notificationsRouterProvider);

    if (user.isLoading) {
      return CircularProgressIndicator();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final follows = ref.watch(followsToMeProvider);

    return Scaffold(
      body: follows.when(
        data: (follows) {
          if (follows.isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No follows yet..."),
                  Text("Share your username with a friend!"),
                ],
              ),
            );
          }

          return ListView(
            children: [
              for (final follow in follows)
                FollowNotificationTile(follow: follow),
            ],
          );
        },
        error: (_, _) => Text("error loading follows"),
        loading: () => Container(),
      ),
    );
  }
}

class FollowNotificationTile extends ConsumerWidget {
  final Follow follow;

  const FollowNotificationTile({super.key, required this.follow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final respondToFollow = ref.read(respondToFollowProvider);

    return ListTile(
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: follow.fromUser.username,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.push('/user/${follow.fromUser.id}');
                },
            ),
            TextSpan(
              text: follow.status == FollowStatus.pending
                  ? ' requested to follow you'
                  : ' followed you',
            ),
          ],
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          context.push('/user/${follow.fromUser.id}');
        },
        child: ProfilePic(image: follow.fromUser.image),
      ),
      trailing: follow.status == FollowStatus.pending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    respondToFollow(
                      follow.fromUser.id,
                      RespondToFollowBody(action: RespondAction.accept),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    respondToFollow(
                      follow.fromUser.id,
                      RespondToFollowBody(action: RespondAction.decline),
                    );
                  },
                ),
              ],
            )
          : null,
    );
  }
}
