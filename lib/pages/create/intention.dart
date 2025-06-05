import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/providers/intentions.dart';

class CreateIntention extends ConsumerStatefulWidget {
  const CreateIntention({super.key});

  @override
  CreateIntentionState createState() => CreateIntentionState();
}

class CreateIntentionState extends ConsumerState {
  final nameController = TextEditingController();

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
              controller: nameController,
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
                    onPressed: () {
                      context.go('/');
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final createIntention = ref.read(createIntentionProvider);
                      createIntention(
                        CreateIntentionBody(name: nameController.text),
                      ).then((_) {
                        print("created intention");
                      });
                    },
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
