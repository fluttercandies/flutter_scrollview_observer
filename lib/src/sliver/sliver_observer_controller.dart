/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class SliverObserverController extends ObserverController
    with ObserverControllerForInfo, ObserverControllerForScroll {
  SliverObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [ScrollViewOnceObserveNotification]
  dispatchOnceObserve({
    required BuildContext sliverContext,
    bool isForce = false,
  }) {
    innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: ScrollViewOnceObserveNotification(
        isForce: isForce,
      ),
    );
  }
}
