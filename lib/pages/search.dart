import 'package:flutter/material.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Search username",
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (var _ in Iterable.generate(10))
                    ListTile(leading: ProfilePic(), title: Text("username")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
