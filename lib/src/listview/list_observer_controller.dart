/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-07-20 00:32:40
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';

class ListObserverController extends ObserverController
    with ObserverControllerForInfo, ObserverControllerForScroll {
  ListObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [ListViewOnceObserveNotification]
  dispatchOnceObserve({
    BuildContext? sliverContext,
    bool isForce = false,
  }) {
    innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: ListViewOnceObserveNotification(isForce: isForce),
    );
  }

  /// Observe the child which is specified index in sliver.
  ListViewObserveDisplayingChildModel? observeItem({
    required int index,
    BuildContext? sliverContext,
  }) {
    final model = findChildInfo(index: index, sliverContext: sliverContext);
    if (model == null) return null;
    return ListViewObserveDisplayingChildModel(
      sliverList: model.sliver as RenderSliverMultiBoxAdaptor,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Observe the first child in sliver.
  ///
  /// Note that the first child here is not the first child being displayed in
  /// sliver, and it may not be displayed.
  ListViewObserveDisplayingChildModel? observeFirstItem({
    BuildContext? sliverContext,
  }) {
    final model = findCurrentFirstChildInfo(sliverContext: sliverContext);
    if (model == null) return null;
    return ListViewObserveDisplayingChildModel(
      sliverList: model.sliver as RenderSliverMultiBoxAdaptor,
      index: model.index,
      renderObject: model.renderObject,
    );
  }
}
