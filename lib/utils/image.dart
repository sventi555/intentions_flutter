import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

Future<String?> toImageDataUrl(XFile image) async {
  final imageBytes = img.encodeJpg(
    img.bakeOrientation(img.decodeImage(await image.readAsBytes())!),
  );
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
