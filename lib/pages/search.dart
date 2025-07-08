import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/models/user.dart';
import 'package:intentions_flutter/pages/intention.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/user.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

final searchRouterProvider = Provider((ref) {
  // we want router state to reset when auth user changes
  ref.watch(authUserProvider);

  return GoRouter(
    routes: [
      GoRoute(path: '/', name: '/', builder: (context, state) => Search()),
      GoRoute(
        path: '/user/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;

          return Profile(
            userId: userId,
            getProfileUri: (String id) => id != userId ? '/user/$userId' : null,
            getIntentionUri: (String intentionId) => '/intention/$intentionId',
          );
        },
      ),
      GoRoute(
        path: '/intention/:intentionId',
        builder: (context, state) {
          final intentionId = state.pathParameters['intentionId']!;

          return Intention(
            intentionId: intentionId,
            getProfileUri: (String userId) => '/user/$userId',
            getIntentionUri: (String id) =>
                id != intentionId ? '/intention/$intentionId' : null,
          );
        },
      ),
    ],
  );
});

class SearchTab extends ConsumerWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(searchRouterProvider);

    return MaterialApp.router(routerConfig: router);
  }
}

class Search extends ConsumerStatefulWidget {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() {
    return _SearchState();
  }
}

class _SearchState extends ConsumerState<Search> {
  final TextEditingController searchController = TextEditingController();
  String? searchedUsername;

  @override
  Widget build(BuildContext context) {
    final searchedUsers = ref.watch(userSearchProvider(searchedUsername));

    final List<User> users = searchedUsers.value ?? [];

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Search username",
                    ),
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  child: Text("search"),
                  onPressed: () {
                    setState(() {
                      searchedUsername = searchController.text;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final user in users)
                    ListTile(
                      onTap: () {
                        context.push('/user/${user.id}');
                      },
                      leading: ProfilePic(image: user.image),
                      title: Text(user.username),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
