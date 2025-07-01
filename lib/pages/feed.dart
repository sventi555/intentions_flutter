import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/expanded_scroll_view.dart';
import 'package:intentions_flutter/widgets/post.dart';

final feedRouterProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => Feed(),
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

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final router = ref.watch(feedRouterProvider);

    if (user.isLoading) {
      return Container();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class Feed extends ConsumerWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(feedProvider.future),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignOutButton(),
            posts.when(
              data: (val) {
                if (val.isEmpty) {
                  return ExpandedScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nothing to show! Try:",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            DefaultTabController.of(context).animateTo(1);
                          },
                          child: Text("following a user"),
                        ),
                        Text("or"),
                        TextButton(
                          onPressed: () {
                            DefaultTabController.of(context).animateTo(2);
                          },
                          child: Text("creating an intention!"),
                        ),
                      ],
                    ),
                  );
                }

                return Expanded(
                  child: ListView(
                    children: val.map((post) => Post(post: post)).toList(),
                  ),
                );
              },
              error: (_, _) => Text('error fetching feed'),
              loading: () => Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text("Sign out"),
      onPressed: () {
        firebase.auth.signOut();
      },
    );
  }
}
