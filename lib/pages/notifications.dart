import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          for (var _ in Iterable.generate(5))
            ListTile(
              title: Text("user requested to follow you"),
              leading: ProfilePic(image: "TODO"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.check), onPressed: () {}),
                  IconButton(icon: Icon(Icons.close), onPressed: () {}),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
