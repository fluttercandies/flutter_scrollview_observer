import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class ListObserverController extends ObserverController
    with ObserverControllerForScroll {
  ListObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [ListViewOnceObserveNotification]
  dispatchOnceObserve({BuildContext? sliverContext}) {
    innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: ListViewOnceObserveNotification(),
    );
  }
}
