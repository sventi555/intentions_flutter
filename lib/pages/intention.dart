import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/widgets/expanded_scroll_view.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/providers/posts.dart';

class Intention extends ConsumerWidget {
  final String intentionId;

  const Intention({super.key, required this.intentionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(intentionPostsProvider(intentionId));
    final intention = ref.watch(intentionProvider(intentionId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          // in case we display stats later...
          ref.refresh(intentionProvider(intentionId).future),
          ref.refresh(intentionPostsProvider(intentionId).future),
        ]),
        child: Column(
          children: [
            intention.when(
              data: (intention) => Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("${intention.user.username}'s intention: "),
                    Text(
                      intention.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              error: (_, _) => Text("error loading intention"),
              loading: () => Container(),
            ),
            Expanded(
              child: posts.when(
                data: (val) {
                  if (val.isEmpty) {
                    return MaxHeightScrollView(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text("No posts with this intention yet..."),
                      ),
                    );
                  }

                  return ListView(
                    children: val.map((post) => Post(post: post)).toList(),
                  );
                },
                error: (_, _) => Text("error loading intention posts"),
                loading: () => Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
