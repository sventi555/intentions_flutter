import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intentions_flutter/providers/image.dart';
import 'package:intentions_flutter/widgets/profile_pic.dart';
import 'package:intentions_flutter/models/post.dart' as post_models;
import 'package:timeago/timeago.dart' as timeago;

class Post extends ConsumerWidget {
  final post_models.Post post;
  final String? Function(String userId) getProfileUri;
  final String? Function(String intentionId) getIntentionUri;

  const Post({
    super.key,
    required this.post,
    required this.getProfileUri,
    required this.getIntentionUri,
  });

  void goToProfile(BuildContext context) {
    final profileUri = getProfileUri(post.userId);
    if (profileUri != null) {
      context.push(profileUri);
    }
  }

  void goToIntention(BuildContext context) {
    final intentionUri = getIntentionUri(post.intentionId);
    if (intentionUri != null) {
      context.push(intentionUri);
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
                  goToIntention(context);
                },
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(post.intention.name),
                  padding: EdgeInsets.all(0),
                ),
              ),
            ],
          ),
        ),
        if (post.image != null)
          imageUrl.when(
            error: (_, _) => Text('error fetching image'),
            loading: () => AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                height: 128,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            ),
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
