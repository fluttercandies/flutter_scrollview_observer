/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-11-03 14:40:40
 */

import 'package:flutter/material.dart';

class ObserverWidgetTagManager extends InheritedWidget {
  final Map<String, BuildContext> _tagMap = {};

  ObserverWidgetTagManager({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  /// Getting the [ObserverWidgetTagManager] instance.
  ///
  /// If the [ObserverWidgetTagManager] instance is not found, return null.
  static ObserverWidgetTagManager? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ObserverWidgetTagManager>();
  }

  /// Setting the tag and context.
  void set(
    String tag,
    BuildContext context,
  ) {
    _tagMap[tag] = context;
  }

  /// Removing the tag.
  void remove(String tag) {
    _tagMap.remove(tag);
  }

  /// Getting the context by tag.
  BuildContext? context(
    String tag,
  ) {
    return _tagMap[tag];
  }

  /// Getting all tags and contexts.
  @protected
  @visibleForTesting
  Map<String, BuildContext> get tagMap {
    return _tagMap;
  }

  @override
  bool updateShouldNotify(covariant ObserverWidgetTagManager oldWidget) {
    return _tagMap != oldWidget._tagMap;
  }
}
