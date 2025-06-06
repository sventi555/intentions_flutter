import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/intention.dart';
import 'package:intentions_flutter/providers/auth_user.dart';

final intentionsProvider = FutureProvider.family<List<Intention>, String>((
  ref,
  userId,
) async {
  final intentions = await firebase.db
      .collection('intentions')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt')
      .get();

  return intentions.docs
      .map((d) => Intention.fromJson(d.id, d.data()))
      .toList();
});

class CreateIntentionBody {
  final String name;

  const CreateIntentionBody({required this.name});
}

Future<void> createIntention(Ref ref, CreateIntentionBody body) async {
  final user = await ref.read(authUserProvider.future);
  final token = await user?.getIdToken();

  await http.post(
    Uri.http('localhost:3001', '/intentions'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({'name': body.name}),
  );
}

final createIntentionProvider = Provider((ref) {
  return (CreateIntentionBody body) async {
    await createIntention(ref, body);
  };
});
