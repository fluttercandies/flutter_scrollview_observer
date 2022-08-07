import 'package:flutter/foundation.dart';
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
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  ///
  /// If you do not pass the [isFixedHeight] parameter, the package will
  /// automatically gradually scroll around the target location before
  /// locating, which will produce an animation.
  jumpTo({
    required int index,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
  }) async {
    await _scrollToIndex(
      index: index,
      isFixedHeight: isFixedHeight,
      sliverContext: sliverContext,
    );
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  animateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
  }) async {
    await _scrollToIndex(
      index: index,
      isFixedHeight: isFixedHeight,
      sliverContext: sliverContext,
      duration: duration,
      curve: curve,
    );
  }

  _scrollToIndex({
    required int index,
    required bool isFixedHeight,
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

    final viewport = _findViewport(obj);
    if (viewport == null) return;

    bool isAnimateTo = (duration != null) && (curve != null);

    // Before the next sliver is shown, it may have an incorrect value for
    // precedingScrollExtent, so we need to scroll around to get
    // precedingScrollExtent correctly.
    double leadingPadding = obj.constraints.precedingScrollExtent;
    final objVisible = obj.geometry?.visible ?? false;
    if (!objVisible && viewport.offset.hasPixels) {
      final viewportOffset = viewport.offset.pixels;
      final isHorizontal = obj.constraints.axis == Axis.horizontal;
      final viewportSize =
          isHorizontal ? viewport.size.width : viewport.size.height;
      final viewportBoundaryExtent =
          viewportSize * 0.5 + (viewport.cacheExtent ?? 0);
      if (leadingPadding > (viewportOffset + viewportBoundaryExtent)) {
        isHandlingScroll = true;
        double targetOffset = leadingPadding - viewportBoundaryExtent;
        final maxScrollExtent = viewportMaxScrollExtent(viewport);
        if (targetOffset > maxScrollExtent) targetOffset = maxScrollExtent;
        await _controller.animateTo(
          targetOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
        await Future.delayed(_findingDuration);
        leadingPadding = obj.constraints.precedingScrollExtent;
      }
    }

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
      if (isAnimateTo) {
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
      } else {
        isHandlingScroll = false;
      }
      return;
    }

    // Because it is fixed height, the offset can be directly calculated for
    // locating.
    if (isFixedHeight) {
      _handleScrollToIndexForFixedHeight(
        obj: obj,
        index: index,
        leadingPadding: leadingPadding,
        duration: duration,
        curve: curve,
      );
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

  /// Scrolling to the specified index location when the child widgets have a
  /// fixed height.
  _handleScrollToIndexForFixedHeight({
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required double leadingPadding,
    Duration? duration,
    Curve? curve,
  }) async {
    assert(controller != null);
    var _controller = controller;
    if (_controller == null || !_controller.hasClients) return;
    isHandlingScroll = true;
    bool isAnimateTo = (duration != null) && (curve != null);

    final targetChild = _findCurrentFirstChild(obj);
    if (targetChild == null) return;
    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    var nextChild = obj.childAfter(targetChild);
    nextChild ??= obj.childBefore(targetChild);
    double separatorTotalHeight = 0;
    if (nextChild != null && nextChild is! RenderIndexedSemantics) {
      // It is separator
      final nextChildPaintBounds = nextChild.paintBounds;
      final nextChildSize = isHorizontal
          ? nextChildPaintBounds.width
          : nextChildPaintBounds.height;
      separatorTotalHeight = index * nextChildSize;
    }
    final childPaintBounds = targetChild.paintBounds;
    final childSize =
        isHorizontal ? childPaintBounds.width : childPaintBounds.height;
    double childLayoutOffset = childSize * index + separatorTotalHeight;
    // Getting safety layout offset.
    childLayoutOffset = _calculateTargetLayoutOffset(
      obj: obj,
      childLayoutOffset: childLayoutOffset,
      childSize: childSize,
    );
    indexOffsetMap[index] = ObserveScrollChildModel(
      layoutOffset: childLayoutOffset,
      size: childSize,
    );
    childLayoutOffset += leadingPadding;
    if (isAnimateTo) {
      Duration _duration =
          isAnimateTo ? duration : const Duration(milliseconds: 1);
      Curve _curve = isAnimateTo ? curve : Curves.linear;
      await _controller.animateTo(
        childLayoutOffset,
        duration: _duration,
        curve: _curve,
      );
    } else {
      _controller.jumpTo(childLayoutOffset);
    }
    if (innerNeedOnceObserveCallBack != null) {
      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        isHandlingScroll = false;
        innerNeedOnceObserveCallBack!();
      });
    } else {
      isHandlingScroll = false;
    }
  }

  /// Scrolling to the specified index location by gradually scrolling around
  /// the target index location.
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

    final viewport = _findViewport(obj);
    if (viewport == null) return;
    final maxScrollExtent = viewportMaxScrollExtent(viewport);

    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    bool isAnimateTo = (duration != null) && (curve != null);

    if (index < firstChildIndex) {
      isHandlingScroll = true;
      final sliverSize =
          isHorizontal ? obj.paintBounds.width : obj.paintBounds.height;
      double childLayoutOffset = 0;
      final firstChild = _findCurrentFirstChild(obj);
      final parentData = firstChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      var targetLeadingOffset = childLayoutOffset - sliverSize;
      if (targetLeadingOffset < 0) {
        targetLeadingOffset = 0;
      }
      double prevPageOffset = targetLeadingOffset + leadingPadding;
      prevPageOffset = prevPageOffset < 0 ? 0 : prevPageOffset;
      if (isAnimateTo) {
        await _controller.animateTo(
          prevPageOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
      } else {
        _controller.jumpTo(prevPageOffset);
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
      final childSize = (isHorizontal
              ? lastChild?.paintBounds.width
              : lastChild?.paintBounds.height) ??
          0;
      double childLayoutOffset = 0;
      final parentData = lastChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      double nextPageOffset = childLayoutOffset + childSize + leadingPadding;
      nextPageOffset =
          nextPageOffset > maxScrollExtent ? maxScrollExtent : nextPageOffset;
      if (isAnimateTo) {
        await _controller.animateTo(
          nextPageOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
      } else {
        _controller.jumpTo(nextPageOffset);
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
          } else {
            isHandlingScroll = false;
          }
        }
        break;
      }
      isHandlingScroll = false;
    }
  }

  /// Getting target safety layout offset for scrolling to index.
  /// This can avoid jitter.
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
    double remainingBottomExtent = scrollExtent - scrollOffset - layoutExtent;
    final needScrollExtent = childLayoutOffset - scrollOffset;

    final viewport = _findViewport(obj);
    if (viewport != null && viewport.offset.hasPixels) {
      final maxScrollExtent = viewportMaxScrollExtent(viewport);
      remainingBottomExtent = maxScrollExtent - viewport.offset.pixels;
    }
    if (remainingBottomExtent < needScrollExtent) {
      targetOffset = scrollExtent - layoutExtent;
    }
    return targetOffset;
  }

  /// Getting [maxScrollExtent] of viewport
  double viewportMaxScrollExtent(RenderViewport viewport) {
    return (viewport.offset as ScrollPositionWithSingleContext).maxScrollExtent;
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

  /// Find out the viewport
  RenderViewport? _findViewport(RenderSliverMultiBoxAdaptor obj) {
    int maxCycleCount = 10;
    int currentCycleCount = 1;
    AbstractNode? parent = obj.parent;
    while (parent != null && currentCycleCount <= maxCycleCount) {
      if (parent is RenderViewport) {
        return parent;
      }
      parent = parent.parent;
      currentCycleCount++;
    }
    return null;
  }
}
