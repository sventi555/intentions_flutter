import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onSubmit() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      var res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'email': email,
          'password': password,
          'isPrivate': true,
        }),
      );

      if (!(res.statusCode >= 200 && res.statusCode < 300)) {
        print(res.statusCode);
        return;
      }

      await firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
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
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("username"),
                  ),
                ),
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
            FilledButton(onPressed: onSubmit, child: Text("Sign up")),
            Column(
              children: [
                Text("Already a user?"),
                TextButton(
                  child: Text("Sign in"),
                  onPressed: () {
                    context.go('/signin');
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
