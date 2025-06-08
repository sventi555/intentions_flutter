import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intentions_flutter/pages/create/intention.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/utils/image.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => CreatePost()),
    GoRoute(path: '/intention', builder: (context, state) => CreateIntention()),
  ],
);

class CreateTab extends StatelessWidget {
  const CreateTab({super.key});

  @override
  Widget build(BuildContext build) {
    return MaterialApp.router(routerConfig: _router);
  }
}

class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({super.key});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  TextEditingController descriptionController = TextEditingController();
  String? selectedIntentionId;
  XFile? image;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authUserProvider).user?.uid;
    final intentions = ref.watch(intentionsProvider(userId ?? ''));

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                  onSelected: (val) {
                    setState(() {
                      selectedIntentionId = val;
                    });
                  },
                  dropdownMenuEntries: switch (intentions) {
                    AsyncData(:final value) => [
                      for (var intention in value)
                        DropdownMenuEntry<String>(
                          label: intention.name,
                          value: intention.id,
                        ),
                    ],
                    _ => [],
                  },
                  label: Text("Select an intention"),
                ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    context.go('/intention');
                  },
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                picker.pickImage(source: ImageSource.gallery).then((img) {
                  setState(() {
                    image = img;
                  });
                });
              },
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_photo_alternate, size: 64),
                    Text("Select an image"),
                  ],
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "description",
                alignLabelWithHint: true,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text("Discard"),
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    child: Text("Post"),
                    onPressed: () async {
                      final createPost = ref.read(createPostProvider);
                      final img = image;
                      createPost(
                            CreatePostBody(
                              intentionId: selectedIntentionId ?? '',
                              image: img != null
                                  ? await toImageDataUrl(img)
                                  : null,
                              description: descriptionController.text,
                            ),
                          )
                          .then((_) {
                            print('created post');
                          })
                          .catchError((e) {
                            print(e);
                          });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
