import 'package:flutter/material.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfilePic(),
                      SizedBox(width: 8),
                      Text("username"),
                    ],
                  ),
                  Text("1 day ago"),
                ],
              ),
              SizedBox(height: 8),
              Chip(label: Text("intention"), padding: EdgeInsets.all(0)),
            ],
          ),
        ),
        Image(
          image: NetworkImage("https://placehold.co/400/png"),
          fit: BoxFit.fill,
        ),
        Container(padding: EdgeInsets.all(8), child: Text("description")),
      ],
    );
  }
}
