/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/models/observe_find_child_model.dart';
import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';
import 'package:scrollview_observer/src/utils/src/log.dart';

import 'models/observe_scroll_child_model.dart';

class ObserverController {
  ObserverController({this.controller});

  /// Target scroll controller.
  final ScrollController? controller;

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

mixin ObserverControllerForNotification<
    M extends ObserveModel,
    R extends ObserverHandleContextsResultModel<M>,
    S extends CommonOnceObserveNotificationResult<M, R>> on ObserverController {
  /// A completer for dispatch once observation
  Completer<S>? innerDispatchOnceObserveCompleter;

  /// Dispatch a observation notification
  Future<S> innerDispatchOnceObserve({
    BuildContext? sliverContext,
    required Notification notification,
  }) {
    Completer<S> completer = Completer();
    innerDispatchOnceObserveCompleter = completer;
    BuildContext? _sliverContext = fetchSliverContext(
      sliverContext: sliverContext,
    );
    notification.dispatch(_sliverContext);
    return completer.future;
  }

  /// Complete the observation notification
  innerHandleDispatchOnceObserveComplete({
    required R? resultModel,
  }) {
    final completer = innerDispatchOnceObserveCompleter;
    if (completer == null) return;
    if (!completer.isCompleted) {
      final isSuccess = resultModel != null;
      final resultType = isSuccess
          ? ObserverWidgetObserveResultType.success
          : ObserverWidgetObserveResultType.interrupted;
      final result = innerCreateOnceObserveNotificationResult(
        resultType: resultType,
        resultModel: resultModel,
      );
      completer.complete(result);
    }
    innerDispatchOnceObserveCompleter = null;
  }

  /// Create a observation notification result.
  S innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required R? resultModel,
  }) {
    // The class being mixed in will implement it and will not return null.
    throw UnimplementedError();
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
    var obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(obj);
    if (viewport == null) return null;
    var targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) return null;
    while (targetChild != null && (targetChild.index != index)) {
      targetChild = findNextChild(obj: obj, currentChild: targetChild);
    }
    if (targetChild == null) return null;
    return ObserveFindChildModel(
      sliver: obj,
      viewport: viewport,
      index: targetChild.index,
      renderObject: targetChild,
    );
  }

  /// Find out the first child widget info in sliver.
  ObserveFindChildModel? findCurrentFirstChildInfo({
    BuildContext? sliverContext,
  }) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    var obj = ObserverUtils.findRenderObject(ctx);
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
    final offset = viewport.offset;
    if (offset is! ScrollPosition) {
      return 0;
    }
    return offset.maxScrollExtent;
  }
}

mixin ObserverControllerForScroll on ObserverControllerForInfo {
  static const Duration _findingDuration = Duration(milliseconds: 1);
  static const Curve _findingCurve = Curves.ease;

  /// Whether to cache the offset when jump to a specified index position.
  /// Defaults to true.
  bool cacheJumpIndexOffset = true;

  /// The initial index position of the scrollView.
  ///
  /// Defaults to zero.
  int get initialIndex => initialIndexModel.index;
  set initialIndex(int index) {
    initialIndexModel = ObserverIndexPositionModel(index: index);
  }

  /// The initial index position model of the scrollView.
  ///
  /// Defaults to ObserverIndexPositionModel(index: 0, sliverContext: null).
  ObserverIndexPositionModel initialIndexModel = ObserverIndexPositionModel(
    index: 0,
  );

  /// The block to return [ObserverIndexPositionModel] which to init index
  /// position.
  ObserverIndexPositionModel Function()? initialIndexModelBlock;

  /// Clear the offset cache that jumping to a specified index location.
  @Deprecated(
      'It will be removed in version 2, please use [clearScrollIndexCache] instead')
  clearIndexOffsetCache(BuildContext? sliverContext) {
    clearScrollIndexCache(sliverContext: sliverContext);
  }

  /// Clear the offset cache that jumping to a specified index location.
  clearScrollIndexCache({BuildContext? sliverContext}) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    if (ctx == null) return;
    indexOffsetMap[ctx]?.clear();
  }

  /// Init index position for scrollView.
  innerInitialIndexPosition() {
    final model = initialIndexModelBlock?.call() ?? initialIndexModel;
    if (model.sliverContext == null && model.index <= 0) return;
    jumpTo(
      index: model.index,
      sliverContext: model.sliverContext,
      isFixedHeight: model.isFixedHeight,
      alignment: model.alignment,
      padding: model.padding,
      offset: model.offset,
    );
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
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    await _scrollToIndex(
      index: index,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      sliverContext: sliverContext,
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
    EdgeInsets padding = EdgeInsets.zero,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    await _scrollToIndex(
      index: index,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      sliverContext: sliverContext,
      duration: duration,
      curve: curve,
      offset: offset,
    );
  }

  _scrollToIndex({
    required int index,
    required bool isFixedHeight,
    required double alignment,
    required EdgeInsets padding,
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
    var obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverMultiBoxAdaptor) return;

    final viewport = _findViewport(obj);
    if (viewport == null) return;

    bool isAnimateTo = (duration != null) && (curve != null);

    // Before the next sliver is shown, it may have an incorrect value for
    // precedingScrollExtent, so we need to scroll around to get
    // precedingScrollExtent correctly.
    final objVisible = obj.geometry?.visible ?? false;
    if (!objVisible && viewport.offset.hasPixels) {
      final maxScrollExtent = viewportMaxScrollExtent(viewport);
      // If the target sliver does not paint any child because it is too far
      // away, we need to let the ScrollView scroll near it first.
      // https://github.com/LinXunFeng/flutter_scrollview_observer/issues/45
      if (obj.firstChild == null) {
        final constraints = obj.constraints;
        final precedingScrollExtent = constraints.precedingScrollExtent;
        double paintScrollExtent =
            precedingScrollExtent + (obj.geometry?.maxPaintExtent ?? 0);
        double targetScrollExtent = precedingScrollExtent;
        if (_controller.position.pixels > paintScrollExtent) {
          targetScrollExtent = paintScrollExtent;
        }
        if (targetScrollExtent > maxScrollExtent) {
          targetScrollExtent = maxScrollExtent;
        }
        innerIsHandlingScroll = true;
        await _controller.animateTo(
          targetScrollExtent,
          duration: _findingDuration,
          curve: _findingCurve,
        );
        await WidgetsBinding.instance.endOfFrame;
        innerIsHandlingScroll = false;
      } else {
        final precedingScrollExtent = obj.constraints.precedingScrollExtent;
        final viewportOffset = viewport.offset.pixels;
        final isHorizontal = obj.constraints.axis == Axis.horizontal;
        final viewportSize =
            isHorizontal ? viewport.size.width : viewport.size.height;
        final viewportBoundaryExtent =
            viewportSize * 0.5 + (viewport.cacheExtent ?? 0);
        if (precedingScrollExtent > (viewportOffset + viewportBoundaryExtent)) {
          innerIsHandlingScroll = true;
          double targetOffset = precedingScrollExtent - viewportBoundaryExtent;
          if (targetOffset > maxScrollExtent) targetOffset = maxScrollExtent;
          await _controller.animateTo(
            targetOffset,
            duration: _findingDuration,
            curve: _findingCurve,
          );
          await WidgetsBinding.instance.endOfFrame;
          innerIsHandlingScroll = false;
        }
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
        padding: padding,
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
        padding: padding,
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
      padding: padding,
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
    required EdgeInsets padding,
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
    final childPaintBounds = targetChild.paintBounds;
    double itemSeparatorHeight = 0;
    int indexLineCount = index;
    if (obj is RenderSliverList || obj is RenderSliverFixedExtentList) {
      // ListView
      var nextChild = obj.childAfter(targetChild);
      nextChild ??= obj.childBefore(targetChild);
      if (nextChild != null && nextChild is! RenderIndexedSemantics) {
        // It is separator
        final nextChildPaintBounds = nextChild.paintBounds;
        itemSeparatorHeight = isHorizontal
            ? nextChildPaintBounds.width
            : nextChildPaintBounds.height;
      }
    } else if (obj is RenderSliverGrid) {
      // GirdView
      double crossAxisSpacing = 0;
      bool isHaveSetCrossAxisSpacing = false;
      var nextChild = obj.childAfter(targetChild);
      var nextChildOrigin =
          nextChild?.localToGlobal(Offset.zero) ?? Offset.zero;
      final targetChildOrigin = targetChild.localToGlobal(Offset.zero);
      while (nextChild != null &&
          (isHorizontal
              ? nextChildOrigin.dx == targetChildOrigin.dx
              : nextChildOrigin.dy == targetChildOrigin.dy)) {
        // calculate crossAxisSpacing
        if (!isHaveSetCrossAxisSpacing) {
          if (isHorizontal) {
            crossAxisSpacing =
                (nextChildOrigin.dy - targetChildOrigin.dy).abs() -
                    childPaintBounds.height;
          } else {
            crossAxisSpacing =
                (nextChildOrigin.dx - targetChildOrigin.dx).abs() -
                    childPaintBounds.width;
          }
          isHaveSetCrossAxisSpacing = true;
        }
        nextChild = obj.childAfter(nextChild);
        nextChildOrigin = nextChild?.localToGlobal(Offset.zero) ?? Offset.zero;
      }
      if (nextChild != null) {
        if (isHorizontal) {
          itemSeparatorHeight =
              (nextChildOrigin.dx - targetChildOrigin.dx).abs() -
                  childPaintBounds.width;
        } else {
          itemSeparatorHeight =
              (nextChildOrigin.dy - targetChildOrigin.dy).abs() -
                  childPaintBounds.height;
        }
      } else {
        var previousChild = obj.childBefore(targetChild);
        var previousChildOrigin =
            previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
        while (previousChild != null &&
            (isHorizontal
                ? previousChildOrigin.dx == targetChildOrigin.dx
                : previousChildOrigin.dy == targetChildOrigin.dy)) {
          // calculate crossAxisSpacing
          if (!isHaveSetCrossAxisSpacing) {
            double crossAxisOriginX1 =
                isHorizontal ? previousChildOrigin.dy : previousChildOrigin.dx;
            previousChild = obj.childBefore(previousChild);
            previousChildOrigin =
                previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
            if (previousChild != null) {
              double crossAxisOriginX2 = isHorizontal
                  ? previousChildOrigin.dy
                  : previousChildOrigin.dx;
              crossAxisSpacing = (crossAxisOriginX1 - crossAxisOriginX2).abs() -
                  (isHorizontal
                      ? childPaintBounds.height
                      : childPaintBounds.width);
              isHaveSetCrossAxisSpacing = true;
            }
          } else {
            previousChild = obj.childBefore(previousChild);
            previousChildOrigin =
                previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
          }
        }
        if (previousChild != null) {
          if (isHorizontal) {
            itemSeparatorHeight =
                (targetChildOrigin.dx - previousChildOrigin.dx).abs() -
                    childPaintBounds.width;
          } else {
            itemSeparatorHeight =
                (targetChildOrigin.dy - previousChildOrigin.dy).abs() -
                    childPaintBounds.height;
          }
        }
      }
      final childCrossAxisSize =
          isHorizontal ? childPaintBounds.height : childPaintBounds.width;
      int itemsPerLine = ((obj.constraints.crossAxisExtent + crossAxisSpacing) /
              (childCrossAxisSize + crossAxisSpacing))
          .round();
      indexLineCount = (index / itemsPerLine).floor();
    }
    final childMainAxisSize =
        isHorizontal ? childPaintBounds.width : childPaintBounds.height;
    double childLayoutOffset =
        (childMainAxisSize + itemSeparatorHeight) * indexLineCount;

    _updateIndexOffsetMap(
      ctx: ctx,
      index: index,
      childLayoutOffset: childLayoutOffset,
      childSize: childMainAxisSize,
    );

    // Getting safety layout offset.
    childLayoutOffset = _calculateTargetLayoutOffset(
      obj: obj,
      childLayoutOffset: childLayoutOffset,
      childSize: childMainAxisSize,
      alignment: alignment,
      padding: padding,
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
    required EdgeInsets padding,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
    double? lastPageTurningOffset,
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
      // The offset of this page turning is the same as the previous one,
      // which means the [index] is wrong.
      if (lastPageTurningOffset == prevPageOffset) {
        innerIsHandlingScroll = false;
        Log.warning('The child corresponding to the index cannot be found.\n'
            'Please make sure the index is correct.');
        return;
      }
      lastPageTurningOffset = prevPageOffset;
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
          padding: padding,
          duration: duration,
          curve: curve,
          offset: offset,
          lastPageTurningOffset: lastPageTurningOffset,
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
      // The offset of this page turning is the same as the previous one,
      // which means the [index] is wrong.
      if (lastPageTurningOffset == nextPageOffset) {
        innerIsHandlingScroll = false;
        Log.warning('The child corresponding to the index cannot be found.\n'
            'Please make sure the index is correct.');
        return;
      }
      lastPageTurningOffset = nextPageOffset;
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
          padding: padding,
          duration: duration,
          curve: curve,
          offset: offset,
          lastPageTurningOffset: lastPageTurningOffset,
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
            padding: padding,
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
    required EdgeInsets padding,
    ObserverLocateIndexOffsetCallback? offset,
  }) {
    final precedingScrollExtent = obj.constraints.precedingScrollExtent;
    double targetItemLeadingPadding = childSize * alignment;
    var targetOffset =
        childLayoutOffset + precedingScrollExtent + targetItemLeadingPadding;
    double scrollOffset = 0;
    double remainingBottomExtent = 0;
    double needScrollExtent = 0;

    if (this is SliverObserverController) {
      final viewport = _findViewport(obj);
      if (viewport != null && viewport.offset.hasPixels) {
        scrollOffset = viewport.offset.pixels;
        final maxScrollExtent = viewportMaxScrollExtent(viewport);
        remainingBottomExtent = maxScrollExtent - scrollOffset;
        needScrollExtent = childLayoutOffset +
            precedingScrollExtent +
            targetItemLeadingPadding -
            scrollOffset;
      }
    } else {
      final constraints = obj.constraints;
      final isVertical = constraints.axis == Axis.vertical;
      final trailingPadding = isVertical ? padding.bottom : padding.right;
      final viewportExtent = constraints.viewportMainAxisExtent;
      final geometry = obj.geometry;
      // The (estimated) total scrollable extent of this sliver.
      double scrollExtent = geometry?.scrollExtent ?? 0;
      scrollOffset = obj.constraints.scrollOffset;
      remainingBottomExtent = scrollExtent +
          precedingScrollExtent +
          trailingPadding -
          scrollOffset -
          viewportExtent;
      needScrollExtent = childLayoutOffset +
          precedingScrollExtent +
          targetItemLeadingPadding -
          scrollOffset;
    }

    final outerOffset = offset?.call(targetOffset) ?? 0;
    needScrollExtent = needScrollExtent - outerOffset;
    // The bottom remaining distance is satisfied to go completely scrolling.
    bool isEnoughScroll = remainingBottomExtent >= needScrollExtent;
    if (!isEnoughScroll) {
      targetOffset = remainingBottomExtent + scrollOffset;
    } else {
      targetOffset = needScrollExtent + scrollOffset;
    }
    // The remainingBottomExtent may be negative when the scrollView has too
    // few items.
    targetOffset = targetOffset.clamp(0, double.maxFinite);
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
