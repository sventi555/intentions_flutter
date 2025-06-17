import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/widgets/password_input.dart';

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

  final _formKey = GlobalKey<FormState>();

  String? emailErr;
  String? passwordErr;
  String? formErr;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onSubmit() async {
    try {
      await firebase.auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          emailErr = 'Enter a valid email address';
        } else if (e.code == 'user-not-found') {
          emailErr = 'No user with that email';
        } else if (e.code == 'wrong-password') {
          passwordErr = 'Incorrect password';
        } else {
          formErr = 'Something went wrong, please try again';
        }
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
                  setState(() {
                    emailErr = null;
                    passwordErr = null;
                    formErr = null;
                  });

                  // need to wait for forcedErrorText to clear
                  // otherwise validate will report "false" for some reason...
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onSubmit();
                  });
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
      ),
    );
  }
}
