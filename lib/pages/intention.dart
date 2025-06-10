import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/providers/posts.dart';

class Intention extends ConsumerWidget {
  final String intentionId;

  const Intention({super.key, required this.intentionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(intentionPostsProvider(intentionId));

    return Scaffold(
      body: posts.when(
        data: (val) =>
            ListView(children: val.map((post) => Post(post: post)).toList()),
        error: (_, _) => Text("error loading intention posts"),
        loading: () => CircularProgressIndicator(),
      ),
    );
  }
}
