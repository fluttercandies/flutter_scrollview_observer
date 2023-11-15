/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-05-28 12:37:41
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class ScrollViewOnceObserveNotification extends Notification {
  /// Whether to return the observation result directly without comparing.
  final bool isForce;

  /// Whether to depend on the observe callback.
  ///
  /// If true, the observe callback will be called when the observation result
  /// come out.
  final bool isDependObserveCallback;
  ScrollViewOnceObserveNotification({
    this.isForce = false,
    this.isDependObserveCallback = true,
  });
}

/// The Notification for Triggering an ListView observation
class ListViewOnceObserveNotification
    extends ScrollViewOnceObserveNotification {
  ListViewOnceObserveNotification({
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) : super(
          isForce: isForce,
          isDependObserveCallback: isDependObserveCallback,
        );
}

/// The Notification for Triggering an GridView observation
class GridViewOnceObserveNotification
    extends ScrollViewOnceObserveNotification {
  GridViewOnceObserveNotification({
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) : super(
          isForce: isForce,
          isDependObserveCallback: isDependObserveCallback,
        );
}

/// A notification of scrolling task.
///
/// Sequence:
/// [ObserverScrollStartNotification] -> [ObserverScrollDecisionNotification]
/// -> [ObserverScrollEndNotification].
class ObserverScrollNotification extends Notification {
  @override
  void dispatch(BuildContext? target) {
    bool isMounted = target?.mounted ?? false;
    if (!isMounted) {
      return;
    }
    super.dispatch(target);
  }
}

/// A notification that a scrolling task has started due to calling the jumpTo
/// or animateTo method of [ObserverController].
class ObserverScrollStartNotification extends ObserverScrollNotification {}

/// A notification that a scrolling task has interrupted due to calling the
/// jumpTo or animateTo method of [ObserverController].
class ObserverScrollInterruptionNotification
    extends ObserverScrollNotification {}

/// A notification that the data of the specified index item is determined
/// during the execution of the scrolling task.
class ObserverScrollDecisionNotification extends ObserverScrollNotification {}

/// A notification that a scrolling task has stopped due to calling the jumpTo
/// or animateTo method of [ObserverController].
class ObserverScrollEndNotification extends ObserverScrollNotification {}
