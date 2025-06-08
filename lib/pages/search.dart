import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/models/user.dart';
import 'package:intentions_flutter/providers/user.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

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
