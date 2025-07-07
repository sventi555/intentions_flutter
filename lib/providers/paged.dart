import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/utils/json.dart';

class PagedNotifierState<T> {
  final List<T> items;
  final bool hasNextPage;

  const PagedNotifierState({required this.items, required this.hasNextPage});
}

abstract class PagedNotifier<T> extends AsyncNotifier<PagedNotifierState<T>> {
  final _pageSize = 10;
  DocumentSnapshot? _lastDoc;
  final T Function(String id, Json json) itemFromJson;

  PagedNotifier({required this.itemFromJson});

  Future<Query<Json>?> itemsQuery();

  @override
  Future<PagedNotifierState<T>> build() async {
    final query = await itemsQuery();
    final firstPage = await query?.limit(_pageSize).get();

    if (firstPage == null) {
      return PagedNotifierState<T>(items: [], hasNextPage: false);
    }

    if (firstPage.size > 0) {
      _lastDoc = firstPage.docs.last;
    }

    return PagedNotifierState<T>(
      items: firstPage.docs.map((d) => itemFromJson(d.id, d.data())).toList(),
      hasNextPage: firstPage.size == _pageSize,
    );
  }

  Future<void> fetchPage() async {
    if (state.isLoading) {
      return;
    }

    final lastDoc = _lastDoc;
    if (lastDoc == null) {
      return;
    }

    final prevState = await future;
    if (!prevState.hasNextPage) {
      return;
    }

    state = AsyncLoading();

    try {
      final query = await itemsQuery();
      final nextPage = await query
          ?.startAfterDocument(lastDoc)
          .limit(_pageSize)
          .get();

      if (nextPage == null) {
        state = AsyncData(prevState);
        return;
      }

      if (nextPage.size > 0) {
        _lastDoc = nextPage.docs.last;
      }

      state = AsyncData(
        PagedNotifierState(
          items: [
            ...prevState.items,
            ...nextPage.docs.map((doc) => itemFromJson(doc.id, doc.data())),
          ],
          hasNextPage: nextPage.size == _pageSize,
        ),
      );
    } catch (err, stackTrace) {
      state = AsyncError(err, stackTrace);
    }
  }
}
