/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-05-28 12:37:41
 */
import 'package:flutter/material.dart';

class ScrollViewOnceObserveNotification extends Notification {
  ScrollViewOnceObserveNotification({
    this.isForce = false,
  });

  final bool isForce;
}

/// The Notification for Triggering an ListView observation
class ListViewOnceObserveNotification
    extends ScrollViewOnceObserveNotification {
  ListViewOnceObserveNotification({
    bool isForce = false,
  }) : super(isForce: isForce);
}

/// The Notification for Triggering an GridView observation
class GridViewOnceObserveNotification
    extends ScrollViewOnceObserveNotification {
  GridViewOnceObserveNotification({
    bool isForce = false,
  }) : super(isForce: isForce);
}
