/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-29 22:47:10
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

mixin ChatObserverScrollPhysicsMixin on ScrollPhysics {
  late final ChatScrollObserver observer;

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final isNeedFixedPosition = observer.innerIsNeedFixedPosition;
    observer.innerIsNeedFixedPosition = false;

    var adjustPosition = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    if (newPosition.extentBefore <= observer.fixedPositionOffset ||
        !isNeedFixedPosition ||
        observer.isRemove) {
      _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
        type: ChatScrollObserverHandlePositionType.none,
        mode: observer.innerMode,
        changeCount: observer.changeCount,
      ));
      return adjustPosition;
    }

    // Customize the adjustPosition.
    double? customAdjustPosition = observer.customAdjustPosition?.call(
      ChatScrollObserverCustomAdjustPositionModel(
        oldPosition: oldPosition,
        newPosition: newPosition,
        isScrolling: isScrolling,
        velocity: velocity,
        adjustPosition: adjustPosition,
        observer: observer,
      ),
    );
    if (customAdjustPosition != null) {
      _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
        type: ChatScrollObserverHandlePositionType.keepPosition,
        mode: observer.innerMode,
        changeCount: observer.changeCount,
      ));
      return customAdjustPosition;
    }

    final model = observer.observeRefItem();
    if (model == null) {
      _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
        type: ChatScrollObserverHandlePositionType.none,
        mode: observer.innerMode,
        changeCount: observer.changeCount,
      ));
      return adjustPosition;
    }

    _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
      type: ChatScrollObserverHandlePositionType.keepPosition,
      mode: observer.innerMode,
      changeCount: observer.changeCount,
    ));

    // Customize the delta of the adjustPosition.
    double? customDelta = observer.customAdjustPositionDelta?.call(
      ChatScrollObserverCustomAdjustPositionDeltaModel(
        oldPosition: oldPosition,
        newPosition: newPosition,
        isScrolling: isScrolling,
        velocity: velocity,
        adjustPosition: adjustPosition,
        observer: observer,
        currentItemModel: model,
      ),
    );

    // Calculate the final delta.
    //
    // If the customDelta is not null, use the customDelta.
    // Otherwise, use the layoutOffset minus innerRefItemLayoutOffset to get
    // the difference in the leading offset of the item.
    final delta =
        customDelta ?? (model.layoutOffset - observer.innerRefItemLayoutOffset);

    return adjustPosition + delta;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  /// Calling observer's [onHandlePositionCallback].
  _handlePositionCallback(ChatScrollObserverHandlePositionResultModel result) {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      observer.onHandlePositionResultCallback?.call(result);
      // ignore: deprecated_member_use_from_same_package
      observer.onHandlePositionCallback?.call(result.type);
    });
  }
}
