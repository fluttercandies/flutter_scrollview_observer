/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-10-27 17:16:57
 */

import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/observer_typedef.dart';

class ObserverListenerEntry<M extends ObserveModel>
    extends LinkedListEntry<ObserverListenerEntry<M>> {
  ObserverListenerEntry({
    required this.context,
    required this.onObserve,
    required this.onObserveAll,
  });

  /// The context of the listener.
  final BuildContext? context;

  /// The callback of getting observed result.
  final OnObserveCallback<M>? onObserve;

  /// The callback of getting observed result map.
  final OnObserveAllCallback<M>? onObserveAll;
}
