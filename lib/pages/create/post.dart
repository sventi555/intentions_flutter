import 'dart:typed_data';

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
import 'package:loader_overlay/loader_overlay.dart';

final createRouterProvider = Provider((ref) {
  final user = ref.watch(authUserProvider).value;
  final intentionsEmpty = ref.watch(emptyIntentionsProvider(user?.uid));

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

          if (intentionsEmpty == true) {
            return '/intention';
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
      return Container();
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
  Uint8List? imageBytes;

  String? errMessage;

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        this.image = image;
      });

      final imageBytes = await image.readAsBytes();
      setState(() {
        this.imageBytes = imageBytes;
      });
    }
  }

  Future<void> onSubmit(BuildContext context, String? intentionId) async {
    final image = this.image;

    // Should redirect to create intention page, but just in case...
    if (intentionId == null) {
      setState(() {
        errMessage = 'Must select an intention';
      });
      return;
    }

    if (image == null && descriptionController.text.isEmpty) {
      setState(() {
        errMessage = 'Must include image or description';
      });
      return;
    }

    final createPost = ref.read(createPostProvider);

    context.loaderOverlay.show();

    await createPost(
      CreatePostBody(
        intentionId: intentionId,
        image: image != null ? await toImageDataUrl(image) : null,
        description: descriptionController.text,
      ),
    );

    if (!context.mounted) return;
    context.loaderOverlay.hide();
    DefaultTabController.of(context).animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider).value;
    if (user == null) {
      throw StateError('must be signed in to see create post page');
    }
    final intentions = ref.watch(
      intentionsProvider(IntentionsProviderArg(userId: user.uid)),
    );

    final imageBytes = this.imageBytes;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Row(
                children: [
                  intentions.when(
                    data: (intentions) => DropdownMenu<String>(
                      enableFilter: true,
                      enabled: intentions.isNotEmpty,
                      initialSelection: intentions.isNotEmpty
                          ? intentions[0].id
                          : null,
                      onSelected: (val) {
                        setState(() {
                          selectedIntentionId = val;
                        });
                      },
                      dropdownMenuEntries: intentions.isNotEmpty
                          ? intentions
                                .map(
                                  (intention) => DropdownMenuEntry(
                                    label: intention.name,
                                    value: intention.id,
                                  ),
                                )
                                .toList()
                          // If the dropdown has no entries, there's a weird visual bug.
                          // Adding a dummy entry since the button will be disabled anyway.
                          : [DropdownMenuEntry(label: '', value: '')],
                      label: Text("Select an intention"),
                    ),
                    error: (_, _) => Text('error loading intentions'),
                    loading: () => Container(),
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
              if (imageBytes != null)
                Image.memory(imageBytes, fit: BoxFit.fill),
              image == null
                  ? GestureDetector(
                      onTap: pickImage,
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
                    )
                  : TextButton(
                      onPressed: pickImage,
                      child: Text("Change image"),
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
              if (errMessage != null)
                Text(
                  errMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
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
                      onPressed: () {
                        onSubmit(
                          context,
                          selectedIntentionId ?? intentions.value?[0].id,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
