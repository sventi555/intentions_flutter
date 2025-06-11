import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intentions_flutter/pages/auth/sign_in.dart';
import 'package:intentions_flutter/pages/auth/sign_up.dart';
import 'package:intentions_flutter/pages/create/intention.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/providers/posts.dart';
import 'package:intentions_flutter/utils/image.dart';

final createRouterProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: '/',
        builder: (context, state) => CreatePost(),
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/intention',
        builder: (context, state) => CreateIntention(),
        redirect: (context, state) {
          if (user == null) {
            return '/signin';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => SignIn(),
        redirect: (context, state) {
          if (user != null) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUp(),
        redirect: (context, state) {
          if (user != null) {
            return '/';
          }
          return null;
        },
      ),
    ],
  );
});

class CreateTab extends ConsumerWidget {
  const CreateTab({super.key});

  @override
  Widget build(BuildContext build, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final router = ref.watch(createRouterProvider);

    if (user.isLoading) {
      return CircularProgressIndicator();
    }

    return MaterialApp.router(routerConfig: router);
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
    final user = ref.watch(authUserProvider).value;
    if (user == null) {
      throw StateError('must be signed in to see create post page');
    }
    final intentions = ref.watch(intentionsProvider(user.uid));

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
                  dropdownMenuEntries: intentions.when(
                    data: (val) => [
                      for (var intention in val)
                        DropdownMenuEntry<String>(
                          label: intention.name,
                          value: intention.id,
                        ),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  label: Text("Select an intention"),
                ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    context.push('/intention');
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
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(0);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    child: Text("Post"),
                    onPressed: () async {
                      final createPost = ref.read(createPostProvider);
                      final img = image;
                      await createPost(
                        CreatePostBody(
                          intentionId: selectedIntentionId ?? '',
                          image: img != null ? await toImageDataUrl(img) : null,
                          description: descriptionController.text,
                        ),
                      );
                      if (!context.mounted) return;
                      DefaultTabController.of(context).animateTo(0);
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
