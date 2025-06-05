import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/firebase.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onSubmit({required Function() onSuccess}) async {
    try {
      await firebase.auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      print(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Text("Intentions", style: TextStyle(fontSize: 32)),
                Text("act intentionally", style: TextStyle(fontSize: 16)),
              ],
            ),
            Column(
              spacing: 4,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("email"),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("password"),
                  ),
                ),
              ],
            ),
            FilledButton(
              onPressed: () {
                onSubmit(
                  onSuccess: () {
                    context.go('/');
                  },
                );
              },
              child: Text("Sign in"),
            ),
            Column(
              children: [
                Text("New user?"),
                TextButton(
                  child: Text("Sign up"),
                  onPressed: () {
                    context.go('/signup');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
