import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/utils/json.dart';

class PagedNotifierState<T> {
  final List<T> items;
  final bool hasNextPage;

  const PagedNotifierState({required this.items, required this.hasNextPage});
}

abstract class PagedNotifier<T> extends AsyncNotifier<PagedNotifierState<T>>
    with _PagedNotifierMixin<T, void> {
  FutureOr<Query<Json>?> itemsQuery();

  @override
  FutureOr<Query<Json>?> _itemsQuery(_) {
    return itemsQuery();
  }

  @override
  FutureOr<PagedNotifierState<T>> build() {
    return buildState(null);
  }
}

abstract class FamilyPagedNotifier<T, P>
    extends FamilyAsyncNotifier<PagedNotifierState<T>, P>
    with _PagedNotifierMixin<T, P> {
  FutureOr<Query<Json>?> itemsQuery(P param);

  @override
  FutureOr<Query<Json>?> _itemsQuery(P param) {
    return itemsQuery(param);
  }

  @override
  FutureOr<PagedNotifierState<T>> build(P param) {
    return buildState(param);
  }
}

mixin _PagedNotifierMixin<T, P> {
  final _pageSize = 10;
  late P _param;
  DocumentSnapshot? _lastDoc;

  T itemFromJson(String id, Json json);
  FutureOr<Query<Json>?> _itemsQuery(P param);

  // from AsyncNotifier
  AsyncValue<PagedNotifierState<T>> get state;
  set state(AsyncValue<PagedNotifierState<T>> val);
  Future<PagedNotifierState<T>> get future;

  Future<PagedNotifierState<T>> buildState(P param) async {
    _param = param;

    final query = await _itemsQuery(param);
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
      final query = await _itemsQuery(this._param);
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
