import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/providers/image.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';
import 'package:intentions_flutter/models/post.dart' as post_models;
import 'package:timeago/timeago.dart' as timeago;

class Post extends ConsumerWidget {
  final post_models.Post post;

  const Post({super.key, required this.post});

  void goToProfile(BuildContext context) {
    final userProfileUri = '/user/${post.userId}';
    final alreadyOnProfile =
        GoRouter.of(context).state.uri.toString() == userProfileUri;
    if (!alreadyOnProfile) {
      context.push('/user/${post.userId}');
    }
  }

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
                      GestureDetector(
                        onTap: () {
                          goToProfile(context);
                        },
                        child: ProfilePic(image: post.user.image),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          goToProfile(context);
                        },
                        child: Text(post.user.username),
                      ),
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
              GestureDetector(
                onTap: () {
                  context.push('/intention/${post.intentionId}');
                },
                child: Chip(
                  label: Text(post.intention.name),
                  padding: EdgeInsets.all(0),
                ),
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
