import 'package:flutter/material.dart';
import 'package:intentions_flutter/widgets/post.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [for (var _ in Iterable.generate(10)) Post()]);
  }
}
