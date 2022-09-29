/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-29 22:47:10
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

mixin ChatObserverScrollPhysicsMixin on ScrollPhysics {
  late final ChatScrollObserver observer;

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final isNeedFixedPosition = observer.isNeedFixedPosition;
    observer.isNeedFixedPosition = false;

    var adjustPosition = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    if (newPosition.extentBefore == 0 ||
        !isNeedFixedPosition ||
        observer.isRemove) {
      return adjustPosition;
    }
    final model = observer.observeRefItem();
    if (model == null) return adjustPosition;

    final delta = model.layoutOffset - observer.refItemLayoutOffset;
    return adjustPosition + delta;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
}
