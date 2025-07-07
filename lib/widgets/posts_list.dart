import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/paged.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/models/post.dart' as post_models;

class PostsList extends ConsumerStatefulWidget {
  final AsyncValue<PagedNotifierState<post_models.Post>> state;
  final Function() fetchPage;

  const PostsList({super.key, required this.state, required this.fetchPage});

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
        ...(state.value?.items ?? []).map((post) => Post(post: post)),
        if (state.isLoading && state.value?.items.isNotEmpty == true)
          Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        if (!state.isLoading && state.value?.hasNextPage == false)
          Container(
            padding: EdgeInsets.all(4),
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
