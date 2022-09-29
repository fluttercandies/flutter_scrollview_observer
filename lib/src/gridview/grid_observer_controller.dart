/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-07-20 00:32:40
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class GridObserverController extends ObserverController
    with ObserverControllerForInfo, ObserverControllerForScroll {
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

  /// Observe the child which is specified index in sliver.
  GridViewObserveDisplayingChildModel? observeItem({
    required int index,
    BuildContext? sliverContext,
  }) {
    final model = findChildInfo(index: index, sliverContext: sliverContext);
    if (model == null) return null;
    return GridViewObserveDisplayingChildModel(
      sliverGrid: model.sliver as RenderSliverGrid,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Observe the first child in sliver.
  ///
  /// Note that the first child here is not the first child being displayed in
  /// sliver, and it may not be displayed.
  GridViewObserveDisplayingChildModel? observeFirstItem({
    BuildContext? sliverContext,
  }) {
    final model = findCurrentFirstChildInfo(sliverContext: sliverContext);
    if (model == null) return null;
    return GridViewObserveDisplayingChildModel(
      sliverGrid: model.sliver as RenderSliverGrid,
      index: model.index,
      renderObject: model.renderObject,
    );
  }
}
