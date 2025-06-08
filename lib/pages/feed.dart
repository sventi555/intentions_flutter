import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/post.dart';

GoRouter _getRouter(User? user) => GoRouter(
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

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authUserProvider);

    if (userState.loading) {
      return CircularProgressIndicator();
    }

    return MaterialApp.router(routerConfig: _getRouter(userState.user));
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
          switch (posts) {
            AsyncData(:final value) => Expanded(
              child: ListView(
                children: value.map((post) => Post(post: post)).toList(),
              ),
            ),
            AsyncError() => Text('error fetching feed'),
            _ => CircularProgressIndicator(),
          },
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
