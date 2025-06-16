import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInput({super.key, required this.controller});

  @override
  State<PasswordInput> createState() {
    return _PasswordInputState();
  }
}

class _PasswordInputState extends State<PasswordInput> {
  var passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !passwordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
        border: OutlineInputBorder(),
        label: Text("password"),
      ),
    );
  }
}
