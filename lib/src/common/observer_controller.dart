import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

import 'models/observe_scroll_child_model.dart';

class ObserverController {
  ObserverController({this.controller});

  /// Target sliver [BuildContext]
  List<BuildContext> sliverContexts = [];

  /// Target scroll controller
  final ScrollController? controller;

  /// The map which stores the offset of child in the sliver
  Map<int, ObserveScrollChildModel> indexOffsetMap = {};

  /// A flag used to ignore unnecessary calculations during scrolling.
  bool isHandlingScroll = false;

  /// The callback to call [ObserverWidget]'s _handleContexts method.
  Function()? innerNeedOnceObserveCallBack;

  /// Dispatch a observe notification
  innerDispatchOnceObserve({
    BuildContext? sliverContext,
    required Notification notification,
  }) {
    BuildContext? _sliverContext = fetchSliverContext(
      sliverContext: sliverContext,
    );
    notification.dispatch(_sliverContext);
  }

  /// Reset all data
  innerReset() {
    indexOffsetMap = {};
    isHandlingScroll = false;
  }

  /// Get the target sliver [BuildContext]
  BuildContext? fetchSliverContext({BuildContext? sliverContext}) {
    BuildContext? _sliverContext = sliverContext;
    if (_sliverContext == null && sliverContexts.isNotEmpty) {
      _sliverContext = sliverContexts.first;
    }
    return _sliverContext;
  }
}

mixin ObserverControllerForScroll on ObserverController {
  static const Duration _findingDuration = Duration(milliseconds: 1);
  static const Curve _findingCurve = Curves.ease;

  /// Jump to the specified index position without animation.
  jumpTo({
    required int index,
    BuildContext? sliverContext,
  }) async {
    await _scrollToIndex(
      index: index,
      sliverContext: sliverContext,
    );
  }

  /// Jump to the specified index position with animation.
  animateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    BuildContext? sliverContext,
  }) async {
    await _scrollToIndex(
      index: index,
      sliverContext: sliverContext,
      duration: duration,
      curve: curve,
    );
  }

  _scrollToIndex({
    required int index,
    BuildContext? sliverContext,
    Duration? duration,
    Curve? curve,
  }) async {
    assert(controller != null);
    var _controller = controller;
    if (_controller == null || !_controller.hasClients) return;

    final ctx = fetchSliverContext(sliverContext: sliverContext);
    var obj = ctx?.findRenderObject();
    if (obj is! RenderSliverMultiBoxAdaptor) return;
    double leadingPadding = obj.constraints.precedingScrollExtent;

    var targetScrollChildModel = indexOffsetMap[index];
    // There is a cache offset, scroll to the offset directly.
    if (targetScrollChildModel != null) {
      isHandlingScroll = true;
      var targetOffset = _calculateTargetLayoutOffset(
        obj: obj,
        childLayoutOffset: targetScrollChildModel.layoutOffset,
        childSize: targetScrollChildModel.size,
      );
      targetOffset += leadingPadding;
      if (duration != null && curve != null) {
        await _controller.animateTo(
          targetOffset,
          duration: duration,
          curve: curve,
        );
      } else {
        _controller.jumpTo(targetOffset);
      }
      if (innerNeedOnceObserveCallBack != null) {
        ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
          isHandlingScroll = false;
          innerNeedOnceObserveCallBack!();
        });
      }
      return;
    }

    // Find the index of the first [RenderIndexedSemantics] child in viewport
    var firstChildIndex = 0;
    var lastChildIndex = 0;
    final firstChild = _findCurrentFirstChild(obj);
    final lastChild = _findCurrentLastChild(obj);
    if (firstChild == null || lastChild == null) return;
    firstChildIndex = firstChild.index;
    lastChildIndex = lastChild.index;

    _handleScrollToIndex(
      obj: obj,
      index: index,
      firstChildIndex: firstChildIndex,
      lastChildIndex: lastChildIndex,
      leadingPadding: leadingPadding,
      duration: duration,
      curve: curve,
    );
  }

  _handleScrollToIndex({
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required int firstChildIndex,
    required int lastChildIndex,
    required double leadingPadding,
    Duration? duration,
    Curve? curve,
  }) async {
    var _controller = controller;
    if (_controller == null || !_controller.hasClients) return;
    bool isAnimateTo = (duration != null) && (curve != null);

    if (index < firstChildIndex) {
      isHandlingScroll = true;
      final sliverHeight = obj.paintBounds.height;
      double childLayoutOffset = 0;
      final firstChild = _findCurrentFirstChild(obj);
      final parentData = firstChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      var targetOffsetY = childLayoutOffset - sliverHeight;
      if (targetOffsetY < 0) {
        targetOffsetY = 0;
      }
      final prevPageOffset = targetOffsetY + leadingPadding;
      if (isAnimateTo) {
        _controller.jumpTo(prevPageOffset);
      } else {
        await _controller.animateTo(
          prevPageOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
      }

      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        final firstChild = _findCurrentFirstChild(obj);
        final lastChild = _findCurrentLastChild(obj);
        if (firstChild == null || lastChild == null) {
          isHandlingScroll = false;
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          obj: obj,
          index: index,
          firstChildIndex: firstChildIndex,
          lastChildIndex: lastChildIndex,
          leadingPadding: leadingPadding,
          duration: duration,
          curve: curve,
        );
      });
    } else if (index > lastChildIndex) {
      isHandlingScroll = true;
      final lastChild = _findCurrentLastChild(obj);
      final childHeight = lastChild?.paintBounds.height ?? 0;
      double childLayoutOffset = 0;
      final parentData = lastChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      final nextPageOffset = childLayoutOffset + childHeight + leadingPadding;
      if (isAnimateTo) {
        _controller.jumpTo(nextPageOffset);
      } else {
        await _controller.animateTo(
          nextPageOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
      }

      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        final firstChild = _findCurrentFirstChild(obj);
        final lastChild = _findCurrentLastChild(obj);
        if (firstChild == null || lastChild == null) {
          isHandlingScroll = false;
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          obj: obj,
          index: index,
          firstChildIndex: firstChildIndex,
          lastChildIndex: lastChildIndex,
          leadingPadding: leadingPadding,
          duration: duration,
          curve: curve,
        );
      });
    } else {
      // Target index child is already in viewport
      if (innerNeedOnceObserveCallBack == null) {
        isHandlingScroll = false;
      }
      var targetChild = obj.firstChild;
      while (targetChild != null) {
        if (targetChild is! RenderIndexedSemantics) {
          targetChild = obj.childAfter(targetChild);
          continue;
        }
        final currentChildIndex = targetChild.index;
        double childLayoutOffset = 0;
        final parentData = targetChild.parentData;
        if (parentData is SliverMultiBoxAdaptorParentData) {
          childLayoutOffset = parentData.layoutOffset ?? 0;
        }
        final isHorizontal = obj.constraints.axis == Axis.horizontal;
        final childPaintBounds = targetChild.paintBounds;
        final childSize =
            isHorizontal ? childPaintBounds.width : childPaintBounds.height;
        indexOffsetMap[currentChildIndex] = ObserveScrollChildModel(
          layoutOffset: childLayoutOffset,
          size: childSize,
        );
        if (currentChildIndex != index) {
          targetChild = obj.childAfter(targetChild);
          continue;
        } else {
          var targetOffset = _calculateTargetLayoutOffset(
            obj: obj,
            childLayoutOffset: childLayoutOffset,
            childSize: childSize,
          );
          targetOffset += leadingPadding;
          if (isAnimateTo) {
            Duration _duration =
                isAnimateTo ? duration : const Duration(milliseconds: 1);
            Curve _curve = isAnimateTo ? curve : Curves.linear;
            await _controller.animateTo(
              targetOffset,
              duration: _duration,
              curve: _curve,
            );
          } else {
            _controller.jumpTo(targetOffset);
          }
          if (innerNeedOnceObserveCallBack != null) {
            ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
              isHandlingScroll = false;
              innerNeedOnceObserveCallBack!();
            });
          }
        }
        break;
      }
    }
  }

  /// Getting target layout offset for scrolling to index
  double _calculateTargetLayoutOffset({
    required RenderSliverMultiBoxAdaptor obj,
    required double childLayoutOffset,
    required double childSize,
  }) {
    var targetOffset = childLayoutOffset;
    final geometry = obj.geometry;
    final layoutExtent = geometry?.layoutExtent ?? 0;
    // The (estimated) total scrollable extent of this sliver.
    final scrollExtent = geometry?.scrollExtent ?? 0;
    final scrollOffset = obj.constraints.scrollOffset;
    final remainingBottomExtent = scrollExtent - scrollOffset - layoutExtent;
    final needScrollExtent = childLayoutOffset - scrollOffset;
    if (remainingBottomExtent < needScrollExtent) {
      targetOffset = scrollExtent - layoutExtent;
    }
    return targetOffset;
  }

  /// Find out the current first child in sliver
  RenderIndexedSemantics? _findCurrentFirstChild(
      RenderSliverMultiBoxAdaptor obj) {
    RenderIndexedSemantics? child;
    final firstChild = obj.firstChild;
    if (firstChild is RenderIndexedSemantics) {
      child = firstChild;
    } else {
      final nextChild = obj.childAfter(firstChild!);
      if (nextChild is RenderIndexedSemantics) {
        child = nextChild;
      }
    }
    return child;
  }

  /// Find out the current last child in sliver
  RenderIndexedSemantics? _findCurrentLastChild(
      RenderSliverMultiBoxAdaptor obj) {
    RenderIndexedSemantics? child;
    final lastChild = obj.lastChild;
    if (lastChild is RenderIndexedSemantics) {
      child = lastChild;
    } else {
      final previousChild = obj.childBefore(lastChild!);
      if (previousChild is RenderIndexedSemantics) {
        child = previousChild;
      }
    }
    return child;
  }
}
