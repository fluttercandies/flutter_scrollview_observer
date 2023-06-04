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
  bool get isNeedFixedPosition => innerIsNeedFixedPosition;
  bool innerIsNeedFixedPosition = false;

  /// The index of the reference.
  int get refItemIndex => innerRefItemIndex;
  int innerRefItemIndex = 0;

  /// The index of the reference after ScrollView children update.
  int get refItemIndexAfterUpdate => innerRefItemIndexAfterUpdate;
  int innerRefItemIndexAfterUpdate = 0;

  /// The [layoutOffset] of the reference.
  double get refItemLayoutOffset => innerRefItemLayoutOffset;
  double innerRefItemLayoutOffset = 0;

  /// Control the [shrinkWrap] properties of the external scroll view.
  bool get isShrinkWrap => innerIsShrinkWrap;
  bool innerIsShrinkWrap = true;

  /// Whether is remove chat data.
  bool isRemove = false;

  /// The number of messages added.
  int changeCount = 1;

  /// The current chat location is retained when the scrollView offset is
  /// greater than [fixedPositionOffset].
  double fixedPositionOffset = 0;

  /// The callback that tells the outside to rebuild the scroll view.
  ///
  /// Such as call [setState] method.
  Function? toRebuildScrollViewCallback;

  /// The result callback for processing chat location.
  ///
  /// This callback will be called when handling in [ClampingScrollPhysics]'s
  /// [adjustPositionForNewDimensions].
  @Deprecated(
      'It will be removed in version 2, please use [onHandlePositionCallback] instead')
  void Function(ChatScrollObserverHandlePositionType)? onHandlePositionCallback;

  /// The result callback for processing chat location.
  ///
  /// This callback will be called when handling in [ClampingScrollPhysics]'s
  /// [adjustPositionForNewDimensions].
  void Function(ChatScrollObserverHandlePositionResultModel)?
      onHandlePositionResultCallback;

  /// The mode of processing.
  ChatScrollObserverHandleMode innerMode = ChatScrollObserverHandleMode.normal;

  /// Observation result of reference subparts after ScrollView children update.
  ListViewObserveDisplayingChildModel? observeRefItem() {
    return observerController.observeItem(
      index: refItemIndexAfterUpdate,
    );
  }

  /// Prepare to adjust position for sliver.
  ///
  /// The [changeCount] parameter is used only when [isRemove] parameter is
  /// false.
  ///
  /// The [mode] parameter is used to specify the processing mode.
  ///
  /// [refItemRelativeIndex] parameter and [refItemRelativeIndexAfterUpdate]
  /// parameter are only used when the mode is
  /// [ChatScrollObserverHandleMode.specified].
  /// Usage: When you insert a new message, assign [refItemRelativeIndex] to the
  /// index of the reference message (latest message) before insertion, and
  /// assign [refItemRelativeIndexAfterUpdate] to the index of the reference
  /// message after insertion, they refer to the index of the same message.
  standby({
    BuildContext? sliverContext,
    bool isRemove = false,
    int changeCount = 1,
    ChatScrollObserverHandleMode mode = ChatScrollObserverHandleMode.normal,
    int refItemRelativeIndex = 0,
    int refItemRelativeIndexAfterUpdate = 0,
  }) {
    innerMode = mode;
    this.isRemove = isRemove;
    this.changeCount = changeCount;
    observeSwitchShrinkWrap();

    final firstItemModel = observerController.observeFirstItem(
      sliverContext: sliverContext,
    );
    if (firstItemModel == null) return;
    int _innerRefItemIndex;
    int _innerRefItemIndexAfterUpdate;
    double _innerRefItemLayoutOffset;
    switch (mode) {
      case ChatScrollObserverHandleMode.normal:
        _innerRefItemIndex = firstItemModel.index;
        _innerRefItemIndexAfterUpdate = _innerRefItemIndex + changeCount;
        _innerRefItemLayoutOffset = firstItemModel.layoutOffset;
        break;
      case ChatScrollObserverHandleMode.generative:
        int index = firstItemModel.index + changeCount;
        final model = observerController.observeItem(
          sliverContext: sliverContext,
          index: index,
        );
        if (model == null) return;
        _innerRefItemIndex = index;
        _innerRefItemIndexAfterUpdate = index;
        _innerRefItemLayoutOffset = model.layoutOffset;
        break;
      case ChatScrollObserverHandleMode.specified:
        int index = firstItemModel.index + refItemRelativeIndex;
        final model = observerController.observeItem(
          sliverContext: sliverContext,
          index: index,
        );
        if (model == null) return;
        _innerRefItemIndex = index;
        _innerRefItemIndexAfterUpdate =
            firstItemModel.index + refItemRelativeIndexAfterUpdate;
        _innerRefItemLayoutOffset = model.layoutOffset;
        break;
    }
    // Record value.
    innerIsNeedFixedPosition = true;
    innerRefItemIndex = _innerRefItemIndex;
    innerRefItemIndexAfterUpdate = _innerRefItemIndexAfterUpdate;
    innerRefItemLayoutOffset = _innerRefItemLayoutOffset;
  }

  observeSwitchShrinkWrap() {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      final ctx = observerController.fetchSliverContext();
      if (ctx == null) return;
      final obj = ObserverUtils.findRenderObject(ctx) as RenderSliver;
      final viewportMainAxisExtent = obj.constraints.viewportMainAxisExtent;
      final scrollExtent = obj.geometry?.scrollExtent ?? 0;
      if (viewportMainAxisExtent >= scrollExtent) {
        if (innerIsShrinkWrap) return;
        innerIsShrinkWrap = true;
        observerController.reattach();
        toRebuildScrollViewCallback?.call();
      } else {
        if (!innerIsShrinkWrap) return;
        innerIsShrinkWrap = false;
        observerController.reattach();
        toRebuildScrollViewCallback?.call();
      }
    });
  }
}
