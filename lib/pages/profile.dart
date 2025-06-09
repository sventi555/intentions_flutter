import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/providers/user.dart';
import 'package:intentions_flutter/utils/image.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';
import 'package:timeago/timeago.dart' as timeago;

final routerProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).user;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (user == null) {
            throw StateError('should redirect to sign in');
          }

          return Profile(userId: user.uid);
        },
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          } else {
            return null;
          }
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
    final userState = ref.watch(authUserProvider);
    final router = ref.watch(routerProvider);

    if (userState.loading) {
      return CircularProgressIndicator();
    }

    return MaterialApp.router(routerConfig: router);
  }
}

class Profile extends ConsumerWidget {
  final String userId;

  const Profile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userVal = ref.watch(userProvider(userId));
    final updateUser = ref.watch(updateUserProvider);

    return userVal.when(
      data: (user) => Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image == null) return;

                      final imageUrl = await toImageDataUrl(image);
                      if (imageUrl == null) return;

                      await updateUser(UpdateUserBody(image: imageUrl));
                    },
                    child: ProfilePic(image: user.image, size: 128),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Text(user.username, style: TextStyle(fontSize: 16)),
                        FilledButton(onPressed: () {}, child: Text("follow")),
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
                      ProfilePosts(userId: userId),
                      ProfileIntentions(userId: userId),
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

  const ProfilePosts({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider(userId));

    return posts.when(
      data: (val) =>
          ListView(children: [for (var post in val) Post(post: post)]),
      error: (_, _) => Text('error fetching posts'),
      loading: () => CircularProgressIndicator(),
    );
  }
}

class ProfileIntentions extends ConsumerWidget {
  final String userId;

  const ProfileIntentions({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentions = ref.watch(intentionsProvider(userId));

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DropdownMenu(
                requestFocusOnTap: false,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: "name", label: "Name"),
                  DropdownMenuEntry(value: "active", label: "Recently active"),
                  DropdownMenuEntry(value: "count", label: "Total posts"),
                ],
              ),
              IconButton(icon: Icon(Icons.keyboard_arrow_up), onPressed: () {}),
            ],
          ),
          Expanded(
            child: intentions.when(
              data: (value) => ListView(
                children: [
                  for (var intention in value)
                    ListTile(
                      title: Text(intention.name),
                      subtitle: Text(
                        timeago.format(
                          DateTime.fromMillisecondsSinceEpoch(
                            intention.createdAt,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                ],
              ),
              error: (_, _) => Text('error fetching intentions'),
              loading: () => CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
