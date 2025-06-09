import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/image.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';
import 'package:intentions_flutter/models/post.dart' as post_models;
import 'package:timeago/timeago.dart' as timeago;

class Post extends ConsumerWidget {
  final post_models.Post post;

  const Post({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(imageUrlProvider(post.image));

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
                      ProfilePic(image: post.user.image),
                      SizedBox(width: 8),
                      Text(post.user.username),
                    ],
                  ),
                  Text(
                    timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(post.createdAt),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Chip(
                label: Text(post.intention.name),
                padding: EdgeInsets.all(0),
              ),
            ],
          ),
        ),
        imageUrl.when(
          error: (_, _) => Text('error fetching image'),
          loading: () => CircularProgressIndicator(),
          data: (url) {
            if (url != null) {
              return Image(image: NetworkImage(url), fit: BoxFit.fill);
            }
            return Container();
          },
        ),
        Container(
          padding: EdgeInsets.all(8),
          child: Text(post.description ?? ''),
        ),
      ],
    );
  }
}
