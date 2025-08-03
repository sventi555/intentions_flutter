import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/models/notification.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/follows.dart';
import 'package:intentions_flutter/providers/notifications.dart';
import 'package:intentions_flutter/widgets/expanded_scroll_view.dart';
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

          return Profile(
            userId: userId,
            getProfileUri: (String id) => id != userId ? '/user/$userId' : null,
            getIntentionUri: (String intentionId) => '/intention/$intentionId',
          );
        },
      ),
      GoRoute(
        path: '/intention/:intentionId',
        builder: (context, state) {
          final intentionId = state.pathParameters['intentionId']!;

          return Intention(
            intentionId: intentionId,
            getProfileUri: (String userId) => '/user/$userId',
            getIntentionUri: (String id) =>
                id != intentionId ? '/intention/$intentionId' : null,
          );
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
      return Container();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: notifications.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return MaxHeightScrollView(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No follows yet..."),
                      Text("Share your username with a friend!"),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              children: notifications.map((notification) {
                if (notification is FollowNotification) {
                  return FollowNotificationTile(follow: notification);
                }
                throw Exception('encountered unknown notification');
              }).toList(),
            );
          },
          error: (_, _) => Text("error loading follows"),
          loading: () => Container(),
        ),
      ),
    );
  }
}

class FollowNotificationTile extends ConsumerWidget {
  final FollowNotification follow;

  const FollowNotificationTile({super.key, required this.follow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final respondToFollow = ref.read(respondToFollowProvider);
    final authUser = ref.watch(authUserProvider).value;
    if (authUser == null) {
      throw StateError('must be signed in to view notifications');
    }

    final isFollowRecipient = follow.toUser.id == authUser.uid;
    final isFollowSender = !isFollowRecipient;
    if (isFollowSender && follow.status != FollowStatus.accepted) {
      throw Exception(
        'should only get notifications as sender when request is accepted',
      );
    }

    final otherUser = isFollowRecipient
        ? follow.fromUser.username
        : follow.toUser.username;

    return ListTile(
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: otherUser,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.push('/user/${follow.fromUser.id}');
                },
            ),
            isFollowRecipient
                ? TextSpan(
                    text: follow.status == FollowStatus.pending
                        ? ' requested to follow you'
                        : ' followed you',
                  )
                : TextSpan(text: ' accepted your follow request'),
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
