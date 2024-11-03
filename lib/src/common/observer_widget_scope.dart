/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-10-19 11:49:39
 */

import 'package:flutter/material.dart';

import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';

class ObserverWidgetScope<
    C extends ObserverController,
    M extends ObserveModel,
    N extends ScrollViewOnceObserveNotification,
    T extends ObserverWidget<C, M, N>> extends InheritedWidget {
  const ObserverWidgetScope({
    Key? key,
    required Widget child,
    required this.observerWidgetState,
    required this.onCreateElement,
  }) : super(key: key, child: child);

  /// The [ObserverWidgetState] instance.
  final ObserverWidgetState<C, M, N, T> observerWidgetState;

  /// The callback of [createElement].
  final Function(BuildContext) onCreateElement;

  @override
  InheritedElement createElement() {
    final element = super.createElement();
    onCreateElement.call(element);
    return element;
  }

  @override
  bool updateShouldNotify(covariant ObserverWidgetScope oldWidget) {
    return observerWidgetState != oldWidget.observerWidgetState;
  }
}
