/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-10-27 20:47:11
 */

import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:scrollview_observer/src/common/observer_typedef.dart';

class SliverObserverListenerEntry
    extends LinkedListEntry<SliverObserverListenerEntry> {
  SliverObserverListenerEntry({
    required this.context,
    required this.onObserveViewport,
  });

  /// The context of the listener.
  final BuildContext? context;

  /// The callback of getting all slivers those are displayed in viewport.
  final OnObserveViewportCallback? onObserveViewport;
}
