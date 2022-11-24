/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-27 23:01:58
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

class ChatScrollObserver {
  ChatScrollObserver(this.observerController);

  /// Used to obtain the necessary child widget information.
  final ListObserverController observerController;

  /// Whether a fixed position is required.
  bool isNeedFixedPosition = false;

  /// The index of the reference.
  int refItemIndex = 0;

  /// The [layoutOffset] of the reference.
  double refItemLayoutOffset = 0;

  /// Control the [shrinkWrap] propertie of the external scroll view.
  bool isShrinkWrap = true;

  /// Whether is remove chat data.
  bool isRemove = false;

  /// The callback that tells the outside to rebuild the scroll view.
  ///
  /// Such as call [setState] method.
  Function? toRebuildScrollViewCallback;

  /// This callback will be called when handling in [ClampingScrollPhysics]'s
  /// [adjustPositionForNewDimensions].
  void Function(ChatScrollObserverHandlePositionType)? onHandlePositionCallback;

  /// Observe the child widget of the reference.
  ListViewObserveDisplayingChildModel? observeRefItem() {
    return observerController.observeItem(index: refItemIndex + 1);
  }

  /// Prepare to adjust position for sliver.
  standby({
    BuildContext? sliverContext,
    bool isRemove = false,
  }) {
    this.isRemove = isRemove;
    observeSwitchShrinkWrap();
    final model = observerController.observeFirstItem(
      sliverContext: sliverContext,
    );
    if (model == null) return;
    isNeedFixedPosition = true;
    refItemIndex = model.index;
    refItemLayoutOffset = model.layoutOffset;
  }

  observeSwitchShrinkWrap() {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      final ctx = observerController.fetchSliverContext();
      if (ctx == null) return;
      final obj = ctx.findRenderObject() as RenderSliver;
      final viewportMainAxisExtent = obj.constraints.viewportMainAxisExtent;
      final scrollExtent = obj.geometry?.scrollExtent ?? 0;
      if (viewportMainAxisExtent >= scrollExtent) {
        if (isShrinkWrap) return;
        isShrinkWrap = true;
        observerController.reattach();
        toRebuildScrollViewCallback?.call();
      } else {
        if (!isShrinkWrap) return;
        isShrinkWrap = false;
        observerController.reattach();
        toRebuildScrollViewCallback?.call();
      }
    });
  }
}
