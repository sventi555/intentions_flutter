import 'package:flutter/material.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    FilledButton(onPressed: () => {}, child: Text("follow")),
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
                  Tab(text: "posts"),
                  Tab(text: "intentions"),
                ],
              ),
              body: const TabBarView(children: [Text("booga"), Text("bunger")]),
            ),
          ),
        ),
      ],
    );
  }
}
