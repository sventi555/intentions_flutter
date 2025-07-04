import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/expanded_scroll_view.dart';
import 'package:intentions_flutter/widgets/post.dart';

final feedRouterProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => Feed(),
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;

          return Profile(userId: userId);
        },
      ),
      GoRoute(
        path: '/intention/:intentionId',
        builder: (context, state) {
          final intentionId = state.pathParameters['intentionId']!;

          return Intention(intentionId: intentionId);
        },
      ),
      GoRoute(
        path: '/signin',
        redirect: (context, state) {
          if (user != null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) => SignIn(),
      ),
      GoRoute(
        path: '/signup',
        redirect: (context, state) {
          if (user != null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) => SignUp(),
      ),
    ],
  );
});

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final router = ref.watch(feedRouterProvider);

    if (user.isLoading) {
      return Container();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class Feed extends ConsumerStatefulWidget {
  const Feed({super.key});

  @override
  ConsumerState<Feed> createState() {
    return _FeedState();
  }
}

class _FeedState extends ConsumerState<Feed> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      final feedState = ref.read(feedProvider);
      final feedNotifier = ref.read(feedProvider.notifier);

      if (!feedState.isLoading && feedState.value?.hasNextPage == true) {
        feedNotifier.fetchPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    final postsList = ListView(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      children: [
        ...(feedState.value?.items ?? []).map((post) => Post(post: post)),
        if (feedState.isLoading && feedState.value?.items.isNotEmpty == true)
          Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        if (!feedState.isLoading && feedState.value?.hasNextPage == false)
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(feedProvider.future),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignOutButton(),
            Expanded(
              child: feedState.when(
                data: (val) {
                  if (val.items.isEmpty) {
                    return MaxHeightScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Nothing to show! Try:",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              DefaultTabController.of(context).animateTo(1);
                            },
                            child: Text("following a user"),
                          ),
                          Text("or"),
                          TextButton(
                            onPressed: () {
                              DefaultTabController.of(context).animateTo(2);
                            },
                            child: Text("creating an intention!"),
                          ),
                        ],
                      ),
                    );
                  }

                  return postsList;
                },
                error: (_, _) => Text('error fetching feed'),
                loading: () => postsList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text("Sign out"),
      onPressed: () {
        firebase.auth.signOut();
      },
    );
  }
}
