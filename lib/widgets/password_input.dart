import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? forceErrorText;

  const PasswordInput({
    super.key,
    required this.controller,
    this.forceErrorText,
  });

  @override
  State<PasswordInput> createState() {
    return _PasswordInputState();
  }
}

class _PasswordInputState extends State<PasswordInput> {
  var passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      forceErrorText: widget.forceErrorText,
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
      validator: (val) {
        if (val == null || val.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
    );
  }
}
