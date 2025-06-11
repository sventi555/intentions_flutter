import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/providers/image.dart';

class ProfilePic extends ConsumerWidget {
  const ProfilePic({super.key, required this.image, this.size = 32});

  final String? image;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(imageUrlProvider(image));

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.secondary,
        ),
        image: DecorationImage(
          image: NetworkImage(
            imageUrl.value ?? "https://placehold.co/${size.toInt()}/png",
          ),
        ),
      ),
      width: size,
      height: size,
    );
  }
}
