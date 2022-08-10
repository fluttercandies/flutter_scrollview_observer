/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class SliverObserverController extends ObserverController
    with ObserverControllerForScroll {
  SliverObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [ListViewOnceObserveNotification] or
  /// [GridViewOnceObserveNotification]
  dispatchOnceObserve({
    required BuildContext sliverContext,
  }) {
    final renderObj = sliverContext.findRenderObject();
    if (renderObj == null) return;
    Notification? notification;
    if (renderObj is RenderSliverList) {
      notification = ListViewOnceObserveNotification();
    } else if (renderObj is RenderSliverGrid) {
      notification = GridViewOnceObserveNotification();
    }
    if (notification == null) return;
    innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: notification,
    );
  }
}
