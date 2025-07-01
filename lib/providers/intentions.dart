import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/intention.dart';
import 'package:intentions_flutter/providers/auth_user.dart';

final intentionProvider = FutureProvider.family<Intention, String>((
  ref,
  intentionId,
) async {
  // user to clear cache when user signs out
  ref.watch(authUserProvider);

  final intention = await firebase.db
      .collection('intentions')
      .doc(intentionId)
      .get();

  final intentionData = intention.data();
  if (intentionData == null) {
    throw Exception('incentive does not exist');
  }

  return Intention.fromJson(intentionId, intentionData);
});

enum IntentionsSortBy { name, postCount, updatedAt }

enum SortDirection { normal, inverse }

class IntentionsProviderArg extends Equatable {
  final String? userId;
  final IntentionsSortBy sortBy;
  final SortDirection sortDir;

  const IntentionsProviderArg({
    this.userId,
    this.sortBy = IntentionsSortBy.updatedAt,
    this.sortDir = SortDirection.normal,
  });

  @override
  get props => [userId, sortBy, sortDir];
}

final intentionsProvider =
    FutureProvider.family<List<Intention>, IntentionsProviderArg>((
      ref,
      arg,
    ) async {
      // user to clear cache when user signs out
      ref.watch(authUserProvider);

      if (arg.userId == null) {
        return [];
      }

      var sortBy = "";
      var desc = false;

      if (arg.sortBy == IntentionsSortBy.name) {
        sortBy = "name";
        desc = arg.sortDir != SortDirection.normal;
      } else if (arg.sortBy == IntentionsSortBy.updatedAt) {
        sortBy = "updatedAt";
        desc = arg.sortDir == SortDirection.normal;
      } else if (arg.sortBy == IntentionsSortBy.postCount) {
        sortBy = "postCount";
        desc = arg.sortDir == SortDirection.normal;
      }

      var intentionsQuery = firebase.db
          .collection('intentions')
          .where('userId', isEqualTo: arg.userId)
          .orderBy(sortBy, descending: desc);

      // secondary sorting of name for non-name primary sorts
      if (sortBy != 'name') {
        intentionsQuery = intentionsQuery.orderBy('name');
      }

      final intentions = await intentionsQuery.get();
      return intentions.docs
          .map((d) => Intention.fromJson(d.id, d.data()))
          .toList();
    });

final emptyIntentionsProvider = Provider.family<bool?, String?>((ref, userId) {
  final intentionsEmpty = ref.watch(
    intentionsProvider(IntentionsProviderArg(userId: userId)).select((
      intentions,
    ) {
      final val = intentions.when(
        data: (vals) => vals.isEmpty,
        loading: () => null,
        error: (_, _) => null,
      );
      return val;
    }),
  );

  return intentionsEmpty;
});

void invalidateIntentions(Ref ref, String userId) {
  for (final sortBy in IntentionsSortBy.values) {
    for (final sortDir in SortDirection.values) {
      ref.invalidate(
        intentionsProvider(
          IntentionsProviderArg(
            userId: userId,
            sortBy: sortBy,
            sortDir: sortDir,
          ),
        ),
      );
    }
  }
}

Future refreshIntentions(WidgetRef ref, String userId) async {
  final refreshes = IntentionsSortBy.values
      .map(
        (sortBy) => SortDirection.values.map(
          (sortDir) => ref.refresh(
            intentionsProvider(
              IntentionsProviderArg(
                userId: userId,
                sortBy: sortBy,
                sortDir: sortDir,
              ),
            ).future,
          ),
        ),
      )
      .expand((i) => i);

  return Future.wait(refreshes);
}

class DuplicateIntentionException {}

class CreateIntentionBody {
  final String name;

  const CreateIntentionBody({required this.name});
}

Future<void> createIntention(Ref ref, CreateIntentionBody body) async {
  final user = await ref.read(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to create intention');
  }
  final token = await user.getIdToken();

  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/intentions'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({'name': body.name}),
  );

  if (res.statusCode == 409) {
    throw DuplicateIntentionException();
  }

  invalidateIntentions(ref, user.uid);
}

final createIntentionProvider = Provider((ref) {
  return (CreateIntentionBody body) async {
    await createIntention(ref, body);
  };
});
