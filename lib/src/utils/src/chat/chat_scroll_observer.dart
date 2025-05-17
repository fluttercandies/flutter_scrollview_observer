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
  ChatScrollObserver(this.observerController) {
    // Ensure isShrinkWrap is correct at the end of this frame.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      observeSwitchShrinkWrap();
    });
  }

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
      'It will be removed in version 2, please use [onHandlePositionResultCallback] instead')
  void Function(ChatScrollObserverHandlePositionType)? onHandlePositionCallback;

  /// The result callback for processing chat location.
  ///
  /// This callback will be called when handling in [ClampingScrollPhysics]'s
  /// [adjustPositionForNewDimensions].
  void Function(ChatScrollObserverHandlePositionResultModel)?
      onHandlePositionResultCallback;

  /// The mode of processing.
  ChatScrollObserverHandleMode innerMode = ChatScrollObserverHandleMode.normal;

  /// Customize the delta of the adjustPosition.
  ///
  /// If the return value is null, the default processing will be performed.
  ChatScrollObserverCustomAdjustPositionDelta? customAdjustPositionDelta;

  /// Customize the scroll position for new viewport dimensions.
  ///
  /// If the return value is null, the default processing will be performed.
  ChatScrollObserverCustomAdjustPosition? customAdjustPosition;

  /// Observation result of reference item after ScrollView children update.
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
  /// Usage: When you insert a new message, assign the index of the reference
  /// message before insertion to [refItemIndex], and assign the index of the
  /// reference message after insertion to [refItemIndexAfterUpdate].
  /// Note that they should refer to the index of the same message.
  standby({
    BuildContext? sliverContext,
    bool isRemove = false,
    int changeCount = 1,
    ChatScrollObserverHandleMode mode = ChatScrollObserverHandleMode.normal,
    ChatScrollObserverRefIndexType refIndexType =
        ChatScrollObserverRefIndexType.relativeIndexStartFromCacheExtent,
    @Deprecated(
        'It will be removed in version 2, please use [refItemIndex] instead')
    int refItemRelativeIndex = 0,
    @Deprecated(
        'It will be removed in version 2, please use [refItemIndexAfterUpdate] instead')
    int refItemRelativeIndexAfterUpdate = 0,
    int refItemIndex = 0,
    int refItemIndexAfterUpdate = 0,
    ChatScrollObserverCustomAdjustPosition? customAdjustPosition,
    ChatScrollObserverCustomAdjustPositionDelta? customAdjustPositionDelta,
  }) async {
    innerMode = mode;
    this.isRemove = isRemove;
    this.changeCount = changeCount;
    observeSwitchShrinkWrap();

    int _innerRefItemIndex;
    int _innerRefItemIndexAfterUpdate;
    double _innerRefItemLayoutOffset;
    switch (mode) {
      case ChatScrollObserverHandleMode.normal:
        final firstItemModel = observerController.observeFirstItem(
          sliverContext: sliverContext,
        );
        if (firstItemModel == null) return;
        _innerRefItemIndex = firstItemModel.index;
        _innerRefItemIndexAfterUpdate = _innerRefItemIndex + changeCount;
        _innerRefItemLayoutOffset = firstItemModel.layoutOffset;
        break;
      case ChatScrollObserverHandleMode.generative:
        final firstItemModel = observerController.observeFirstItem(
          sliverContext: sliverContext,
        );
        if (firstItemModel == null) return;
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
        // Prioritize the values ​​of [refItemIndex] and [refItemIndexAfterUpdate]
        int _refItemIndex =
            refItemIndex != 0 ? refItemIndex : refItemRelativeIndex;
        int _refItemIndexAfterUpdate = refItemIndexAfterUpdate != 0
            ? refItemIndexAfterUpdate
            : refItemRelativeIndexAfterUpdate;

        switch (refIndexType) {
          case ChatScrollObserverRefIndexType.relativeIndexStartFromCacheExtent:
            final firstItemModel = observerController.observeFirstItem(
              sliverContext: sliverContext,
            );
            if (firstItemModel == null) return;
            int index = firstItemModel.index + _refItemIndex;
            final model = observerController.observeItem(
              sliverContext: sliverContext,
              index: index,
            );
            if (model == null) return;
            _innerRefItemIndex = index;
            _innerRefItemIndexAfterUpdate =
                firstItemModel.index + _refItemIndexAfterUpdate;
            _innerRefItemLayoutOffset = model.layoutOffset;
            break;
          case ChatScrollObserverRefIndexType.relativeIndexStartFromDisplaying:
            final observeResult = await observerController.dispatchOnceObserve(
              isForce: true,
              isDependObserveCallback: false,
            );
            if (!observeResult.isSuccess) return;
            final currentFirstDisplayingChildIndex =
                observeResult.observeResult?.firstChild?.index ?? 0;
            int index = currentFirstDisplayingChildIndex + _refItemIndex;
            final model = observerController.observeItem(
              sliverContext: sliverContext,
              index: index,
            );
            if (model == null) return;
            _innerRefItemIndex = index;
            _innerRefItemIndexAfterUpdate =
                currentFirstDisplayingChildIndex + _refItemIndexAfterUpdate;
            _innerRefItemLayoutOffset = model.layoutOffset;
            break;
          case ChatScrollObserverRefIndexType.itemIndex:
            final model = observerController.observeItem(
              sliverContext: sliverContext,
              index: _refItemIndex,
            );
            if (model == null) return;
            _innerRefItemIndex = _refItemIndex;
            _innerRefItemIndexAfterUpdate = _refItemIndexAfterUpdate;
            _innerRefItemLayoutOffset = model.layoutOffset;
            break;
        }
    }
    // Record value.
    innerIsNeedFixedPosition = true;
    innerRefItemIndex = _innerRefItemIndex;
    innerRefItemIndexAfterUpdate = _innerRefItemIndexAfterUpdate;
    innerRefItemLayoutOffset = _innerRefItemLayoutOffset;
    this.customAdjustPosition = customAdjustPosition;
    this.customAdjustPositionDelta = customAdjustPositionDelta;

    // When the heights of items are similar, the viewport will not call
    // [performLayout], In this case, the [adjustPositionForNewDimensions] of
    // [ScrollPhysics] will not be called, which makes the function of keeping
    // position invalid.
    //
    // So here let it record a layout-time correction to the scroll offset, and
    // call [markNeedsLayout] to prompt the viewport to be re-layout to solve
    // the above problem.
    //
    // Related issue
    // https://github.com/fluttercandies/flutter_scrollview_observer/issues/64
    final ctx = observerController.fetchSliverContext();
    if (ctx == null) return;
    final obj = ObserverUtils.findRenderObject(ctx);
    if (obj == null) return;
    final viewport = ObserverUtils.findViewport(obj);
    if (viewport == null) return;
    if (!viewport.offset.hasPixels) return;
    viewport.offset.correctBy(0);
    viewport.markNeedsLayout();
  }

  observeSwitchShrinkWrap() {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      final ctx = observerController.fetchSliverContext();
      if (ctx == null) return;
      final obj = ObserverUtils.findRenderObject(ctx);
      if (obj is! RenderSliver) return;
      final constraints = ObserverUtils.sliverConstraints(obj);
      if (constraints == null) return;
      final viewportMainAxisExtent = constraints.viewportMainAxisExtent;
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
