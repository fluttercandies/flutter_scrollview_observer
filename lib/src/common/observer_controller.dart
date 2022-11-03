/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/models/observe_find_child_model.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

import 'models/observe_scroll_child_model.dart';

class ObserverController {
  ObserverController({this.controller});

  /// Target scroll controller.
  final ScrollController? controller;

  /// Whether to cache the offset when jump to a specified index position.
  /// Default is true.
  bool cacheJumpIndexOffset = true;

  /// The map which stores the offset of child in the sliver
  Map<BuildContext, Map<int, ObserveScrollChildModel>> indexOffsetMap = {};

  /// Target sliver [BuildContext]
  List<BuildContext> sliverContexts = [];

  /// A flag used to ignore unnecessary calculations during scrolling.
  bool innerIsHandlingScroll = false;

  /// The callback to call [ObserverWidget]'s [_handleContexts] method.
  Function()? innerNeedOnceObserveCallBack;

  /// The callback to call [ObserverWidget]'s [_setupSliverController] method.
  Function()? innerReattachCallBack;

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
    innerIsHandlingScroll = false;
  }

  /// Get the target sliver [BuildContext]
  BuildContext? fetchSliverContext({BuildContext? sliverContext}) {
    BuildContext? _sliverContext = sliverContext;
    if (_sliverContext == null && sliverContexts.isNotEmpty) {
      _sliverContext = sliverContexts.first;
    }
    return _sliverContext;
  }

  /// Get the latest target sliver [BuildContext] and reset some of the old data.
  reattach() {
    if (innerReattachCallBack == null) return;
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      innerReattachCallBack!();
    });
  }
}

mixin ObserverControllerForInfo on ObserverController {
  /// Find out the current first child in sliver
  RenderIndexedSemantics? findCurrentFirstChild(
    RenderSliverMultiBoxAdaptor obj,
  ) {
    RenderIndexedSemantics? child;
    final firstChild = obj.firstChild;
    if (firstChild == null) return null;
    if (firstChild is RenderIndexedSemantics) {
      child = firstChild;
    } else {
      final nextChild = obj.childAfter(firstChild);
      if (nextChild is RenderIndexedSemantics) {
        child = nextChild;
      }
    }
    return child;
  }

  /// Find out the next child in sliver
  RenderIndexedSemantics? findNextChild({
    required RenderSliverMultiBoxAdaptor obj,
    RenderBox? currentChild,
  }) {
    RenderIndexedSemantics? child;
    if (currentChild == null) return null;
    var nextChild = obj.childAfter(currentChild);
    if (nextChild == null) return null;
    if (nextChild is RenderIndexedSemantics) {
      child = nextChild;
    } else {
      nextChild = obj.childAfter(nextChild);
      if (nextChild is RenderIndexedSemantics) {
        child = nextChild;
      }
    }
    return child;
  }

  /// Find out the current last child in sliver
  RenderIndexedSemantics? findCurrentLastChild(
      RenderSliverMultiBoxAdaptor obj) {
    RenderIndexedSemantics? child;
    final lastChild = obj.lastChild;
    if (lastChild == null) return null;
    if (lastChild is RenderIndexedSemantics) {
      child = lastChild;
    } else {
      final previousChild = obj.childBefore(lastChild);
      if (previousChild is RenderIndexedSemantics) {
        child = previousChild;
      }
    }
    return child;
  }

  /// Find out the child widget info for specified index in sliver.
  ObserveFindChildModel? findChildInfo({
    required int index,
    BuildContext? sliverContext,
  }) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    var obj = ctx?.findRenderObject();
    if (obj is! RenderSliverMultiBoxAdaptor) return null;
    var targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) return null;
    while (targetChild != null && (targetChild.index != index)) {
      targetChild = findNextChild(obj: obj, currentChild: targetChild);
    }
    if (targetChild == null) return null;
    return ObserveFindChildModel(
      sliver: obj,
      index: targetChild.index,
      renderObject: targetChild,
    );
  }

  /// Find out the first child widget info in sliver.
  ObserveFindChildModel? findCurrentFirstChildInfo({
    BuildContext? sliverContext,
  }) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    var obj = ctx?.findRenderObject();
    if (obj == null || obj is! RenderSliverMultiBoxAdaptor) return null;
    final targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) return null;
    final index = targetChild.index;
    return findChildInfo(index: index, sliverContext: sliverContext);
  }

  /// Find out the viewport
  RenderViewportBase? _findViewport(RenderSliverMultiBoxAdaptor obj) {
    return ObserverUtils.findViewport(obj);
  }

  /// Getting [maxScrollExtent] of viewport
  double viewportMaxScrollExtent(RenderViewportBase viewport) {
    return (viewport.offset as ScrollPositionWithSingleContext).maxScrollExtent;
  }
}

mixin ObserverControllerForScroll on ObserverControllerForInfo {
  static const Duration _findingDuration = Duration(milliseconds: 1);
  static const Curve _findingCurve = Curves.ease;

  /// Clear the offset cache that jumping to a specified index location.
  clearIndexOffsetCache(BuildContext? sliverContext) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    if (ctx == null) return;
    indexOffsetMap[ctx]?.clear();
  }

  /// Jump to the specified index position without animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  ///
  /// If you do not pass the [isFixedHeight] parameter, the package will
  /// automatically gradually scroll around the target location before
  /// locating, which will produce an animation.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  jumpTo({
    required int index,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    await _scrollToIndex(
      index: index,
      isFixedHeight: isFixedHeight,
      sliverContext: sliverContext,
      alignment: alignment,
      offset: offset,
    );
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  animateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    await _scrollToIndex(
      index: index,
      isFixedHeight: isFixedHeight,
      sliverContext: sliverContext,
      duration: duration,
      curve: curve,
      alignment: alignment,
      offset: offset,
    );
  }

  _scrollToIndex({
    required int index,
    required bool isFixedHeight,
    required double alignment,
    BuildContext? sliverContext,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    assert(alignment.clamp(0, 1) == alignment,
        'The [alignment] is expected to be a value in the range [0.0, 1.0]');
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
    double precedingScrollExtent = obj.constraints.precedingScrollExtent;
    final objVisible = obj.geometry?.visible ?? false;
    if (!objVisible && viewport.offset.hasPixels) {
      final viewportOffset = viewport.offset.pixels;
      final isHorizontal = obj.constraints.axis == Axis.horizontal;
      final viewportSize =
          isHorizontal ? viewport.size.width : viewport.size.height;
      final viewportBoundaryExtent =
          viewportSize * 0.5 + (viewport.cacheExtent ?? 0);
      if (precedingScrollExtent > (viewportOffset + viewportBoundaryExtent)) {
        innerIsHandlingScroll = true;
        double targetOffset = precedingScrollExtent - viewportBoundaryExtent;
        final maxScrollExtent = viewportMaxScrollExtent(viewport);
        if (targetOffset > maxScrollExtent) targetOffset = maxScrollExtent;
        await _controller.animateTo(
          targetOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
        await Future.delayed(_findingDuration);
        precedingScrollExtent = obj.constraints.precedingScrollExtent;
      }
    }

    var targetScrollChildModel = indexOffsetMap[ctx]?[index];
    // There is a cache offset, scroll to the offset directly.
    if (targetScrollChildModel != null) {
      innerIsHandlingScroll = true;
      var targetOffset = _calculateTargetLayoutOffset(
        obj: obj,
        childLayoutOffset: targetScrollChildModel.layoutOffset,
        childSize: targetScrollChildModel.size,
        alignment: alignment,
        offset: offset,
      );
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
          innerIsHandlingScroll = false;
          innerNeedOnceObserveCallBack!();
        });
      } else {
        innerIsHandlingScroll = false;
      }
      return;
    }

    // Because it is fixed height, the offset can be directly calculated for
    // locating.
    if (isFixedHeight) {
      _handleScrollToIndexForFixedHeight(
        ctx: ctx!,
        obj: obj,
        index: index,
        alignment: alignment,
        duration: duration,
        curve: curve,
        offset: offset,
      );
      return;
    }

    // Find the index of the first [RenderIndexedSemantics] child in viewport
    var firstChildIndex = 0;
    var lastChildIndex = 0;
    final firstChild = findCurrentFirstChild(obj);
    final lastChild = findCurrentLastChild(obj);
    if (firstChild == null || lastChild == null) return;
    firstChildIndex = firstChild.index;
    lastChildIndex = lastChild.index;

    _handleScrollToIndex(
      ctx: ctx!,
      obj: obj,
      index: index,
      alignment: alignment,
      firstChildIndex: firstChildIndex,
      lastChildIndex: lastChildIndex,
      duration: duration,
      curve: curve,
      offset: offset,
    );
  }

  /// Scrolling to the specified index location when the child widgets have a
  /// fixed height.
  _handleScrollToIndexForFixedHeight({
    required BuildContext ctx,
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required double alignment,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    assert(controller != null);
    var _controller = controller;
    if (_controller == null || !_controller.hasClients) return;
    innerIsHandlingScroll = true;
    bool isAnimateTo = (duration != null) && (curve != null);

    final targetChild = findCurrentFirstChild(obj);
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

    _updateIndexOffsetMap(
      ctx: ctx,
      index: index,
      childLayoutOffset: childLayoutOffset,
      childSize: childSize,
    );

    // Getting safety layout offset.
    childLayoutOffset = _calculateTargetLayoutOffset(
      obj: obj,
      childLayoutOffset: childLayoutOffset,
      childSize: childSize,
      alignment: alignment,
      offset: offset,
    );
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
        innerIsHandlingScroll = false;
        innerNeedOnceObserveCallBack!();
      });
    } else {
      innerIsHandlingScroll = false;
    }
  }

  /// Scrolling to the specified index location by gradually scrolling around
  /// the target index location.
  _handleScrollToIndex({
    required BuildContext ctx,
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required double alignment,
    required int firstChildIndex,
    required int lastChildIndex,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    var _controller = controller;
    if (_controller == null || !_controller.hasClients) return;

    final viewport = _findViewport(obj);
    if (viewport == null) return;
    final maxScrollExtent = viewportMaxScrollExtent(viewport);

    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    bool isAnimateTo = (duration != null) && (curve != null);
    final precedingScrollExtent = obj.constraints.precedingScrollExtent;

    if (index < firstChildIndex) {
      innerIsHandlingScroll = true;
      final sliverSize =
          isHorizontal ? obj.paintBounds.width : obj.paintBounds.height;
      double childLayoutOffset = 0;
      final firstChild = findCurrentFirstChild(obj);
      final parentData = firstChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      var targetLeadingOffset = childLayoutOffset - sliverSize;
      if (targetLeadingOffset < 0) {
        targetLeadingOffset = 0;
      }
      double prevPageOffset = targetLeadingOffset + precedingScrollExtent;
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
        final firstChild = findCurrentFirstChild(obj);
        final lastChild = findCurrentLastChild(obj);
        if (firstChild == null || lastChild == null) {
          innerIsHandlingScroll = false;
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          ctx: ctx,
          obj: obj,
          index: index,
          alignment: alignment,
          firstChildIndex: firstChildIndex,
          lastChildIndex: lastChildIndex,
          duration: duration,
          curve: curve,
          offset: offset,
        );
      });
    } else if (index > lastChildIndex) {
      innerIsHandlingScroll = true;
      final lastChild = findCurrentLastChild(obj);
      final childSize = (isHorizontal
              ? lastChild?.paintBounds.width
              : lastChild?.paintBounds.height) ??
          0;
      double childLayoutOffset = 0;
      final parentData = lastChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      double nextPageOffset =
          childLayoutOffset + childSize + precedingScrollExtent;
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
        final firstChild = findCurrentFirstChild(obj);
        final lastChild = findCurrentLastChild(obj);
        if (firstChild == null || lastChild == null) {
          innerIsHandlingScroll = false;
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          ctx: ctx,
          obj: obj,
          index: index,
          alignment: alignment,
          firstChildIndex: firstChildIndex,
          lastChildIndex: lastChildIndex,
          duration: duration,
          curve: curve,
          offset: offset,
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
        _updateIndexOffsetMap(
          ctx: ctx,
          index: currentChildIndex,
          childLayoutOffset: childLayoutOffset,
          childSize: childSize,
        );
        if (currentChildIndex != index) {
          targetChild = obj.childAfter(targetChild);
          continue;
        } else {
          var targetOffset = _calculateTargetLayoutOffset(
            obj: obj,
            childLayoutOffset: childLayoutOffset,
            childSize: childSize,
            alignment: alignment,
            offset: offset,
          );
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
              innerIsHandlingScroll = false;
              innerNeedOnceObserveCallBack!();
            });
          } else {
            innerIsHandlingScroll = false;
          }
        }
        break;
      }
      innerIsHandlingScroll = false;
    }
  }

  /// Getting target safety layout offset for scrolling to index.
  /// This can avoid jitter.
  double _calculateTargetLayoutOffset({
    required RenderSliverMultiBoxAdaptor obj,
    required double childLayoutOffset,
    required double childSize,
    required double alignment,
    ObserverLocateIndexOffsetCallback? offset,
  }) {
    double precedingScrollExtent = obj.constraints.precedingScrollExtent;
    double leadingPadding = childSize * alignment;
    var targetOffset =
        childLayoutOffset + precedingScrollExtent + leadingPadding;
    final geometry = obj.geometry;
    final layoutExtent = geometry?.layoutExtent ?? 0;
    // The (estimated) total scrollable extent of this sliver.
    double scrollExtent = geometry?.scrollExtent ?? 0;
    double scrollOffset = obj.constraints.scrollOffset;
    double remainingBottomExtent = scrollExtent - scrollOffset - layoutExtent;
    double needScrollExtent = childLayoutOffset - scrollOffset;

    final viewport = _findViewport(obj);
    double viewportPixels = 0;
    if (viewport != null && viewport.offset.hasPixels) {
      viewportPixels = viewport.offset.pixels;
      final maxScrollExtent = viewportMaxScrollExtent(viewport);
      remainingBottomExtent = maxScrollExtent - viewportPixels;
      needScrollExtent = targetOffset;
      scrollExtent = maxScrollExtent;
    }

    // The bottom remaining distance is satisfied to go completely scrolling.
    bool isEnoughScroll = remainingBottomExtent >= needScrollExtent;
    if (!isEnoughScroll) {
      targetOffset = scrollExtent;
    }
    final outerOffset = offset?.call(targetOffset) ?? 0;

    if (!isEnoughScroll) {
      // The distance between the target child widget and the leading of the
      // viewport.
      final childLeadingMarginToViewport = childLayoutOffset +
          precedingScrollExtent +
          leadingPadding -
          targetOffset;
      if (childLeadingMarginToViewport < outerOffset) {
        // The distance between the target child and the leading of the viewport
        // overlaps with the specified offset.
        // Such as: target child widget is obscured by the sticky header.
        targetOffset -= outerOffset - childLeadingMarginToViewport;
      }
    } else {
      if (targetOffset >= outerOffset) {
        targetOffset -= outerOffset;
      } else {
        targetOffset = 0;
      }
    }

    return targetOffset;
  }

  /// Update the [indexOffsetMap] property.
  _updateIndexOffsetMap({
    required BuildContext ctx,
    required int index,
    required double childLayoutOffset,
    required double childSize,
  }) {
    // No need to cache
    if (!cacheJumpIndexOffset) return;
    // To cache offset
    final map = indexOffsetMap[ctx] ?? {};
    map[index] = ObserveScrollChildModel(
      layoutOffset: childLayoutOffset,
      size: childSize,
    );
    indexOffsetMap[ctx] = map;
  }
}
