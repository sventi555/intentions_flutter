import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/widgets/password_input.dart';
import 'package:loader_overlay/loader_overlay.dart';

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

  String? usernameErr;
  String? emailErr;
  String? passwordErr;
  String? formErr;

  final _formKey = GlobalKey<FormState>();

  void resetErrors() {
    setState(() {
      usernameErr = null;
      emailErr = null;
      passwordErr = null;
      formErr = null;
    });
  }

  void onSubmit(BuildContext context) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.loaderOverlay.show();

    final email = emailController.text;
    final password = passwordController.text;

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'email': email,
          'password': password,
        }),
      );

      final code = res.statusCode;
      final ok = code >= 200 && code < 300;
      if (!(ok)) {
        setState(() {
          if (code == 400 && res.body == 'invalid email') {
            emailErr = 'Enter a valid email address';
          } else if (code == 400 && res.body == 'invalid password') {
            passwordErr = 'Password must be at least 8 characters long';
          } else if (code == 409 && res.body == 'username already taken') {
            usernameErr = 'Username already taken';
          } else if (code == 409 && res.body == 'email already taken') {
            emailErr = 'Email already taken';
          } else {
            formErr = 'Something went wrong, please try again';
          }
        });

        return;
      }

      // I think too risky to hide AFTER signing in, because the context
      // may not be mounted anymore and the loader will be stuck.
      // So we hide it before signing in...
      if (!context.mounted) return;
      context.loaderOverlay.hide();

      await firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      setState(() {
        formErr = 'Something went wrong, please try again';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
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
                  TextFormField(
                    forceErrorText: usernameErr,
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("username"),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Enter a username";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    forceErrorText: emailErr,
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("email"),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Enter an email";
                      }
                      return null;
                    },
                  ),
                  PasswordInput(
                    controller: passwordController,
                    forceErrorText: passwordErr,
                  ),
                ],
              ),
              if (formErr != null)
                Text(
                  formErr!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              FilledButton(
                onPressed: () {
                  resetErrors();

                  // need to wait for forcedErrorText to clear
                  // otherwise validate will report "false"
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onSubmit(context);
                  });
                },
                child: Text("Sign up"),
              ),
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
      ),
    );
  }
}
