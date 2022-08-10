/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-07-20 00:32:40
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class GridObserverController extends ObserverController
    with ObserverControllerForScroll {
  GridObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [GridViewOnceObserveNotification]
  dispatchOnceObserve({BuildContext? sliverContext}) {
    innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: GridViewOnceObserveNotification(),
    );
  }
}
