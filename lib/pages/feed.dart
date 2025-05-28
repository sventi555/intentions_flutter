import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intentions_flutter/notifiers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:provider/provider.dart';

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => Feed()),
    );
  }
}

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthUserNotifier>(
        builder: (_, userNotifier, _) => ListView(
          children: [
            TextButton(
              child: userNotifier.user != null
                  ? Text("Sign out")
                  : Text("Sign in"),
              onPressed: () {
                if (userNotifier.user != null) {
                  FirebaseAuth.instance.signOut();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SignIn(
                        redirectTo: MaterialPageRoute(builder: (_) => Feed()),
                      ),
                    ),
                  );
                }
              },
            ),
            for (var _ in Iterable.generate(10)) Post(),
          ],
        ),
      ),
    );
  }
}
