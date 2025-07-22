import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/paged.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/models/post.dart' as post_models;

class PostsList extends ConsumerStatefulWidget {
  final AsyncValue<PagedNotifierState<post_models.Post>> state;
  final Function() fetchPage;

  final String? Function(String userId) getProfileUri;
  final String? Function(String intentionId) getIntentionUri;

  const PostsList({
    super.key,
    required this.state,
    required this.fetchPage,
    required this.getProfileUri,
    required this.getIntentionUri,
  });

  @override
  ConsumerState<PostsList> createState() {
    return _PostsListState();
  }
}

class _PostsListState extends ConsumerState<PostsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      final state = widget.state;

      if (!state.isLoading && state.value?.hasNextPage == true) {
        widget.fetchPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      children: [
        ...(state.value?.items ?? []).map(
          (post) => Column(
            children: [
              Post(
                post: post,
                getProfileUri: widget.getProfileUri,
                getIntentionUri: widget.getIntentionUri,
              ),
              if (post.id != state.value?.items.last.id) SizedBox(height: 8),
            ],
          ),
        ),
        if (state.isLoading && state.value?.items.isNotEmpty == true)
          Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        if (!state.isLoading && state.value?.hasNextPage == false)
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              "no more posts...",
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
      ],
    );
  }
}
