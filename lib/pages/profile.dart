import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/widgets/post.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => Profile()),
    GoRoute(path: '/intention', builder: (context, state) => Intention()),
  ],
);

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext build) {
    return MaterialApp.router(routerConfig: _router);
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              spacing: 8,
              children: [
                ProfilePic(size: 128),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      Text("username", style: TextStyle(fontSize: 16)),
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
                body: const TabBarView(
                  children: [ProfilePosts(), ProfileIntentions()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePosts extends ConsumerWidget {
  const ProfilePosts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authUserProvider).value?.uid;
    final posts = ref.watch(postsProvider(userId ?? ''));

    return switch (posts) {
      AsyncData(:final value) => ListView(
        children: [for (var post in value) Post()],
      ),
      AsyncError() => Text('Oops'),
      _ => CircularProgressIndicator(),
    };
  }
}

class ProfileIntentions extends StatelessWidget {
  const ProfileIntentions({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView(
              children: [
                for (var i in Iterable.generate(5))
                  ListTile(
                    title: Text("intention $i"),
                    subtitle: Text("active 1 day ago"),
                    onTap: () {
                      context.go('/intention');
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
