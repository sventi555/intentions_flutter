import 'package:flutter/material.dart';

class CreateIntention extends StatelessWidget {
  const CreateIntention({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hint: Text("e.g. touch grass"),
              ),
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    style: FilledButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () => {},
                    child: Text("Create"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
