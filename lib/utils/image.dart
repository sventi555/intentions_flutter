import 'dart:convert';

import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> toImageDataUrl(XFile image) async {
  final rotatedImage = await FlutterExifRotation.rotateImage(path: image.path);

  final imageBytes = await rotatedImage.readAsBytes();
  final base64Image = base64Encode(imageBytes);

  var mimeType = image.mimeType;
  if (mimeType == null) {
    try {
      final ext = image.name.toLowerCase().split('.').last;
      if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == 'png' || ext == 'webp') {
        mimeType = 'image/$ext';
      } else {
        // need better error handling here...
        return null;
      }
    } catch (e) {
      // need better error handling here...
      return null;
    }
  }

  return 'data:$mimeType;base64,$base64Image';
}
