import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/widgets/expanded_scroll_view.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/posts_list.dart';

class Intention extends ConsumerWidget {
  final String intentionId;

  final String? Function(String userId) getProfileUri;
  final String? Function(String intentionId) getIntentionUri;

  const Intention({
    super.key,
    required this.intentionId,
    required this.getProfileUri,
    required this.getIntentionUri,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intention = ref.watch(intentionProvider(intentionId));
    final postsState = ref.watch(intentionPostsProvider(intentionId));
    final postsNotifier = ref.watch(
      intentionPostsProvider(intentionId).notifier,
    );

    final postsList = PostsList(
      state: postsState,
      fetchPage: postsNotifier.fetchPage,
      getProfileUri: getProfileUri,
      getIntentionUri: getIntentionUri,
    );

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
              child: postsState.when(
                data: (val) {
                  if (val.items.isEmpty) {
                    return MaxHeightScrollView(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text("No posts with this intention yet..."),
                      ),
                    );
                  }

                  return postsList;
                },
                error: (_, _) => Text("error loading intention posts"),
                loading: () => postsList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
