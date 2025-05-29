import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/notifiers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:provider/provider.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Feed(),
      redirect: (context, state) {
        if (context.read<AuthUserNotifier>().user == null) {
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

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
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
