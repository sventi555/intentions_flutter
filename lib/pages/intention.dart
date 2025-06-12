import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

class Intention extends ConsumerWidget {
  final String intentionId;

  const Intention({super.key, required this.intentionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(intentionPostsProvider(intentionId));
    final intention = ref.watch(intentionProvider(intentionId));

    return Scaffold(
      body: Column(
        children: [
          intention.when(
            data: (intention) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfilePic(image: intention.user.image),
                      SizedBox(width: 4),
                      Text(intention.user.username),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(intention.name),
                  ),
                ],
              ),
            ),
            error: (_, _) => Text("error loading intention"),
            loading: () => CircularProgressIndicator(),
          ),
          posts.when(
            data: (val) => Expanded(
              child: ListView(
                children: val.map((post) => Post(post: post)).toList(),
              ),
            ),
            error: (_, _) => Text("error loading intention posts"),
            loading: () => CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
