import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/widgets/post.dart';

GoRouter _getRouter(User? user) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Feed(),
      redirect: (context, state) {
        if (user == null) {
          return '/signin';
        } else {
          return null;
        }
      },
    ),
    GoRoute(path: '/signin', builder: (context, state) => SignIn()),
    GoRoute(path: '/signup', builder: (context, state) => SignUp()),
  ],
);

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value;
    return MaterialApp.router(routerConfig: _getRouter(user));
  }
}

class Feed extends StatelessWidget {
  const Feed({super.key});

  signOut({required Function() onSuccess}) async {
    await FirebaseAuth.instance.signOut();

    onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TextButton(
            child: Text("Sign out"),
            onPressed: () {
              signOut(
                onSuccess: () {
                  context.go('/signin');
                },
              );
            },
          ),
          for (var _ in Iterable.generate(10)) Post(),
        ],
      ),
    );
  }
}
