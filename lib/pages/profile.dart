import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/follows.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/providers/user.dart';
import 'package:intentions_flutter/utils/image.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';
import 'package:timeago/timeago.dart' as timeago;

final profileRouterProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => MyProfile(),
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          } else {
            return null;
          }
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

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final router = ref.watch(profileRouterProvider);

    if (user.isLoading) {
      return CircularProgressIndicator();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class MyProfile extends ConsumerWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider).value;
    if (authUser == null) {
      throw StateError('must be signed in to see my profile');
    }

    return Profile(userId: authUser.uid);
  }
}

class Profile extends ConsumerWidget {
  final String userId;

  const Profile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    final profileUser = ref.watch(userProvider(userId));
    final follow = ref.watch(followFromMeProvider(userId)).value;
    final isSelf = userId == authUser.value?.uid;

    final updateUser = ref.watch(updateUserProvider);
    final followUser = ref.watch(followUserProvider);
    final unfollowUser = ref.watch(unfollowUserProvider);

    String followButtonText = 'follow';
    if (follow != null) {
      followButtonText = follow.status == FollowStatus.pending
          ? 'pending'
          : 'unfollow';
    }
    return profileUser.when(
      data: (user) => Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: isSelf
                        ? () async {
                            final ImagePicker picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image == null) return;

                            final imageUrl = await toImageDataUrl(image);
                            if (imageUrl == null) return;

                            await updateUser(UpdateUserBody(image: imageUrl));
                          }
                        : null,
                    child: ProfilePic(image: user.image, size: 128),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Text(user.username, style: TextStyle(fontSize: 16)),
                        if (!isSelf)
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: follow != null
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              follow == null
                                  ? followUser(userId)
                                  : unfollowUser(userId);
                            },
                            child: Text(followButtonText),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DefaultTabController(
              length: 2,
              child: Expanded(
                child: Scaffold(
                  appBar: TabBar(
                    tabs: [
                      Tab(text: "Posts"),
                      Tab(text: "Intentions"),
                    ],
                  ),
                  body: TabBarView(
                    children: [
                      ProfilePosts(
                        userId: userId,
                        onClickCreatePost: () {
                          DefaultTabController.of(context).animateTo(2);
                        },
                      ),
                      ProfileIntentions(
                        userId: userId,
                        onClickCreateIntention: () {
                          DefaultTabController.of(context).animateTo(2);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => Text('error fetching user'),
      loading: () => CircularProgressIndicator(),
    );
  }
}

class ProfilePosts extends ConsumerWidget {
  final String userId;
  final Function() onClickCreatePost;

  const ProfilePosts({
    super.key,
    required this.userId,
    required this.onClickCreatePost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    final posts = ref.watch(postsProvider(userId));

    return posts.when(
      data: (value) {
        if (value.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No posts yet..."),
              if (authUser.value?.uid == userId)
                TextButton(
                  onPressed: onClickCreatePost,
                  child: Text("create a post!"),
                ),
            ],
          );
        }

        return ListView(children: [for (var post in value) Post(post: post)]);
      },
      error: (_, _) => Text('error fetching posts'),
      loading: () => CircularProgressIndicator(),
    );
  }
}

class ProfileIntentions extends ConsumerStatefulWidget {
  final String userId;
  final Function() onClickCreateIntention;

  const ProfileIntentions({
    super.key,
    required this.userId,
    required this.onClickCreateIntention,
  });

  @override
  ConsumerState<ProfileIntentions> createState() {
    return _ProfileIntentionsState();
  }
}

class _ProfileIntentionsState extends ConsumerState<ProfileIntentions> {
  final defaultSort = IntentionsSortBy.updatedAt;
  IntentionsSortBy sortBy = IntentionsSortBy.updatedAt;
  SortDirection sortDir = SortDirection.normal;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);

    final intentions = ref.watch(
      intentionsProvider(
        IntentionsProviderArg(
          userId: widget.userId,
          sortBy: sortBy,
          sortDir: sortDir,
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DropdownMenu(
                initialSelection: defaultSort,
                onSelected: (sort) {
                  setState(() {
                    if (sort != null) {
                      sortBy = sort;
                    }
                  });
                },
                requestFocusOnTap: false,
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: IntentionsSortBy.updatedAt,
                    label: "Recently active",
                  ),
                  DropdownMenuEntry(
                    value: IntentionsSortBy.name,
                    label: "Name",
                  ),
                  DropdownMenuEntry(
                    value: IntentionsSortBy.postCount,
                    label: "Total posts",
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  sortDir == SortDirection.normal
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    sortDir = sortDir == SortDirection.normal
                        ? SortDirection.inverse
                        : SortDirection.normal;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: intentions.when(
              data: (value) {
                if (value.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No intentions yet..."),
                      if (authUser.value?.uid == widget.userId)
                        TextButton(
                          onPressed: widget.onClickCreateIntention,
                          child: Text("create an intention!"),
                        ),
                    ],
                  );
                }

                return ListView(
                  children: [
                    for (var intention in value)
                      ListTile(
                        title: Text(intention.name),
                        subtitle: sortBy != IntentionsSortBy.name
                            ? Text(
                                sortBy == IntentionsSortBy.updatedAt
                                    ? timeago.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          intention.createdAt,
                                        ),
                                      )
                                    : '${intention.postCount} posts',
                              )
                            : null,
                        onTap: () {
                          context.push('/intention/${intention.id}');
                        },
                      ),
                  ],
                );
              },
              error: (_, _) => Text('error fetching intentions'),
              loading: () => CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
