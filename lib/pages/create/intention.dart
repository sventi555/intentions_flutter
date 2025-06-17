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
                if (context.canPop())
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text("Cancel"),
                    ),
                  ),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final createIntention = ref.read(createIntentionProvider);
                      await createIntention(
                        CreateIntentionBody(name: nameController.text),
                      );

                      if (!context.mounted) return;
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
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
