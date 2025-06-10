import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/post.dart';

final routerProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
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
    final router = ref.watch(routerProvider);

    if (user.isLoading) {
      return CircularProgressIndicator();
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
      body: Column(
        children: [
          SignOutButton(),
          posts.when(
            data: (val) => Expanded(
              child: ListView(
                children: val.map((post) => Post(post: post)).toList(),
              ),
            ),
            error: (_, _) => Text('error fetching feed'),
            loading: () => CircularProgressIndicator(),
          ),
        ],
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
