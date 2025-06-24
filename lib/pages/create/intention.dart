import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CreateIntention extends ConsumerStatefulWidget {
  const CreateIntention({super.key});

  @override
  CreateIntentionState createState() => CreateIntentionState();
}

class CreateIntentionState extends ConsumerState {
  final nameController = TextEditingController();
  String? intentionErr;
  bool isValid = false;

  Future<void> onSubmit(BuildContext context) async {
    context.loaderOverlay.show();

    final createIntention = ref.read(createIntentionProvider);
    try {
      await createIntention(CreateIntentionBody(name: nameController.text));

      if (context.mounted) context.loaderOverlay.hide();
    } on DuplicateIntentionException catch (_) {
      if (context.mounted) context.loaderOverlay.hide();

      setState(() {
        intentionErr = 'Intention with same name already exists';
      });
      return;
    }

    if (!context.mounted) return;

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Text("Create an intention"),
            TextFormField(
              forceErrorText: intentionErr,
              controller: nameController,
              onChanged: (val) {
                setState(() {
                  isValid = val.isNotEmpty;
                });
              },
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
                    onPressed: isValid
                        ? () {
                            onSubmit(context);
                          }
                        : null,
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
