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
import 'package:scrollview_observer/src/common/models/observe_scroll_to_index_fixed_height_result_model.dart';
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

  /// Whether to forbid the onObserve callback and onObserveAll callback.
  bool isForbidObserveCallback = false;

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
    innerJumpTo(
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
  /// fixed, please pass the [isFixedHeight] parameter and the
  /// [renderSliverType] parameter.
  ///
  /// If you do not pass the [isFixedHeight] parameter, the package will
  /// automatically gradually scroll around the target location before
  /// locating, which will produce an animation.
  ///
  /// The [renderSliverType] parameter is used to specify the type of sliver.
  /// If you do not pass the [renderSliverType] parameter, the sliding position
  /// will be calculated based on the actual type of obj, and there may be
  /// deviations in the calculation of elements for third-party libraries.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  Future innerJumpTo({
    required int index,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) {
    Completer completer = Completer();
    _scrollToIndex(
      completer: completer,
      index: index,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      sliverContext: sliverContext,
      offset: offset,
      renderSliverType: renderSliverType,
    );
    return completer.future;
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter and the
  /// [renderSliverType] parameter.
  ///
  /// The [renderSliverType] parameter is used to specify the type of sliver.
  /// If you do not pass the [renderSliverType] parameter, the sliding position
  /// will be calculated based on the actual type of obj, and there may be
  /// deviations in the calculation of elements for third-party libraries.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  Future innerAnimateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    EdgeInsets padding = EdgeInsets.zero,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) {
    Completer completer = Completer();
    _scrollToIndex(
      completer: completer,
      index: index,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      sliverContext: sliverContext,
      duration: duration,
      curve: curve,
      offset: offset,
      renderSliverType: renderSliverType,
    );
    return completer.future;
  }

  _scrollToIndex({
    required Completer completer,
    required int index,
    required bool isFixedHeight,
    required double alignment,
    required EdgeInsets padding,
    BuildContext? sliverContext,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) async {
    assert(alignment.clamp(0, 1) == alignment,
        'The [alignment] is expected to be a value in the range [0.0, 1.0]');
    assert(controller != null);
    var _controller = controller;
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    if (_controller == null || !_controller.hasClients) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    var obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverMultiBoxAdaptor) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    final viewport = _findViewport(obj);
    if (viewport == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    // Start executing scrolling task.
    _handleScrollStart(context: ctx);

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
        await _controller.animateTo(
          targetScrollExtent,
          duration: _findingDuration,
          curve: _findingCurve,
        );
        await WidgetsBinding.instance.endOfFrame;
      } else {
        final precedingScrollExtent = obj.constraints.precedingScrollExtent;
        final viewportOffset = viewport.offset.pixels;
        final isHorizontal = obj.constraints.axis == Axis.horizontal;
        final viewportSize =
            isHorizontal ? viewport.size.width : viewport.size.height;
        final viewportBoundaryExtent =
            viewportSize * 0.5 + (viewport.cacheExtent ?? 0);
        if (precedingScrollExtent > (viewportOffset + viewportBoundaryExtent)) {
          double targetOffset = precedingScrollExtent - viewportBoundaryExtent;
          if (targetOffset > maxScrollExtent) targetOffset = maxScrollExtent;
          await _controller.animateTo(
            targetOffset,
            duration: _findingDuration,
            curve: _findingCurve,
          );
          await WidgetsBinding.instance.endOfFrame;
        }
      }
    }

    var targetScrollChildModel = indexOffsetMap[ctx]?[index];
    // There is a cache offset, scroll to the offset directly.
    if (targetScrollChildModel != null) {
      _handleScrollDecision(context: ctx);
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
      _handleScrollEnd(context: ctx, completer: completer);
      return;
    }

    // Because it is fixed height, the offset can be directly calculated for
    // locating.
    if (isFixedHeight) {
      _handleScrollToIndexForFixedHeight(
        completer: completer,
        ctx: ctx!,
        obj: obj,
        index: index,
        alignment: alignment,
        padding: padding,
        duration: duration,
        curve: curve,
        offset: offset,
        renderSliverType: renderSliverType,
      );
      return;
    }

    // Find the index of the first [RenderIndexedSemantics] child in viewport
    var firstChildIndex = 0;
    var lastChildIndex = 0;
    final firstChild = findCurrentFirstChild(obj);
    final lastChild = findCurrentLastChild(obj);
    if (firstChild == null || lastChild == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    firstChildIndex = firstChild.index;
    lastChildIndex = lastChild.index;

    _handleScrollToIndex(
      completer: completer,
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
    required Completer completer,
    required BuildContext ctx,
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required double alignment,
    required EdgeInsets padding,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) async {
    assert(controller != null);
    var _controller = controller;
    if (_controller == null || !_controller.hasClients) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    bool isAnimateTo = (duration != null) && (curve != null);

    final targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    ObserveScrollToIndexFixedHeightResultModel resultModel;
    if (obj is RenderSliverList ||
        obj is RenderSliverFixedExtentList ||
        renderSliverType == ObserverRenderSliverType.list) {
      // ListView
      resultModel = _calculateScrollToIndexForFixedHeightResultForList(
        obj: obj,
        targetChild: targetChild,
        index: index,
      );
    } else if (obj is RenderSliverGrid ||
        renderSliverType == ObserverRenderSliverType.grid) {
      // GirdView
      resultModel = _calculateScrollToIndexForFixedHeightResultForGrid(
        obj: obj,
        targetChild: targetChild,
        index: index,
      );
    } else {
      // Other
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    _handleScrollDecision(context: ctx);

    double childMainAxisSize = resultModel.childMainAxisSize;
    double childLayoutOffset = resultModel.targetChildLayoutOffset;

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
    _handleScrollEnd(context: ctx, completer: completer);
  }

  /// Scrolling to the specified index location by gradually scrolling around
  /// the target index location.
  _handleScrollToIndex({
    required Completer completer,
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
    if (_controller == null || !_controller.hasClients) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    final viewport = _findViewport(obj);
    if (viewport == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    final maxScrollExtent = viewportMaxScrollExtent(viewport);

    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    bool isAnimateTo = (duration != null) && (curve != null);
    final precedingScrollExtent = obj.constraints.precedingScrollExtent;

    if (index < firstChildIndex) {
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
        Log.warning('The child corresponding to the index cannot be found.\n'
            'Please make sure the index is correct.');
        _handleScrollInterruption(context: ctx, completer: completer);
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
          _handleScrollInterruption(context: ctx, completer: completer);
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          completer: completer,
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
        Log.warning('The child corresponding to the index cannot be found.\n'
            'Please make sure the index is correct.');
        _handleScrollInterruption(context: ctx, completer: completer);
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
          _handleScrollInterruption(context: ctx, completer: completer);
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          completer: completer,
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
          _handleScrollDecision(context: ctx);

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

          _handleScrollEnd(context: ctx, completer: completer);
        }
        break;
      }
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

  /// Calculate the information about scrolling to the specified index location
  /// when the type is ObserverRenderSliverType.list.
  ObserveScrollToIndexFixedHeightResultModel
      _calculateScrollToIndexForFixedHeightResultForList({
    required RenderSliverMultiBoxAdaptor obj,
    required RenderIndexedSemantics targetChild,
    required int index,
  }) {
    final childPaintBounds = targetChild.paintBounds;
    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    // The separator size between items on the main axis.
    double itemSeparatorHeight = 0;

    /// The size of item on the main axis.
    final childMainAxisSize =
        isHorizontal ? childPaintBounds.width : childPaintBounds.height;

    var nextChild = obj.childAfter(targetChild);
    nextChild ??= obj.childBefore(targetChild);
    if (nextChild != null && nextChild is! RenderIndexedSemantics) {
      // It is separator
      final nextChildPaintBounds = nextChild.paintBounds;
      itemSeparatorHeight = isHorizontal
          ? nextChildPaintBounds.width
          : nextChildPaintBounds.height;
    }
    // Calculate the offset of the target child widget on the main axis.
    double targetChildLayoutOffset =
        (childMainAxisSize + itemSeparatorHeight) * index;

    return ObserveScrollToIndexFixedHeightResultModel(
      childMainAxisSize: childMainAxisSize,
      itemSeparatorHeight: itemSeparatorHeight,
      indexOfLine: index,
      targetChildLayoutOffset: targetChildLayoutOffset,
    );
  }

  /// Calculate the information about scrolling to the specified index location
  /// when the type is ObserverRenderSliverType.grid.
  ObserveScrollToIndexFixedHeightResultModel
      _calculateScrollToIndexForFixedHeightResultForGrid({
    required RenderSliverMultiBoxAdaptor obj,
    required RenderIndexedSemantics targetChild,
    required int index,
  }) {
    final childPaintBounds = targetChild.paintBounds;
    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    // The separator size between items on the main axis.
    double itemSeparatorHeight = 0;
    // The number of rows for the target item.
    int indexOfLine = index;

    /// The size of item on the main axis.
    final childMainAxisSize =
        isHorizontal ? childPaintBounds.width : childPaintBounds.height;

    double crossAxisSpacing = 0;
    bool isHaveSetCrossAxisSpacing = false;
    var nextChild = obj.childAfter(targetChild);
    // Find the next child that is not on the same line and calculate the
    // mainAxisSpacing.
    var nextChildOrigin = nextChild?.localToGlobal(Offset.zero) ?? Offset.zero;
    final targetChildOrigin = targetChild.localToGlobal(Offset.zero);
    while (nextChild != null &&
        (isHorizontal
            ? nextChildOrigin.dx == targetChildOrigin.dx
            : nextChildOrigin.dy == targetChildOrigin.dy)) {
      if (!isHaveSetCrossAxisSpacing) {
        // Find the next child on the same line and calculate the
        // crossAxisSpacing.
        if (isHorizontal) {
          crossAxisSpacing = (nextChildOrigin.dy - targetChildOrigin.dy).abs() -
              childPaintBounds.height;
        } else {
          crossAxisSpacing = (nextChildOrigin.dx - targetChildOrigin.dx).abs() -
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
      // Can't find the next child that is not on the same line.
      // Find the before child that is not on the same line and calculate the
      // mainAxisSpacing.
      var previousChild = obj.childBefore(targetChild);
      var previousChildOrigin =
          previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
      while (previousChild != null &&
          (isHorizontal
              ? previousChildOrigin.dx == targetChildOrigin.dx
              : previousChildOrigin.dy == targetChildOrigin.dy)) {
        if (!isHaveSetCrossAxisSpacing) {
          // Find two child on the same line and calculate the
          // crossAxisSpacing.
          double firstBeforeCrossAxisOrigin =
              isHorizontal ? previousChildOrigin.dy : previousChildOrigin.dx;
          previousChild = obj.childBefore(previousChild);
          previousChildOrigin =
              previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
          if (previousChild != null) {
            double secondBeforeCrossAxisOrigin =
                isHorizontal ? previousChildOrigin.dy : previousChildOrigin.dx;
            crossAxisSpacing =
                (firstBeforeCrossAxisOrigin - secondBeforeCrossAxisOrigin)
                        .abs() -
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
    // Calculate the number of lines.
    // round() for avoiding precision errors.
    int itemsPerLine = ((obj.constraints.crossAxisExtent + crossAxisSpacing) /
            (childCrossAxisSize + crossAxisSpacing))
        .round();
    // Calculate the number of lines.
    indexOfLine = (index / itemsPerLine).floor();
    // Calculate the offset of the target child widget on the main axis.
    double targetChildLayoutOffset =
        (childMainAxisSize + itemSeparatorHeight) * indexOfLine;

    return ObserveScrollToIndexFixedHeightResultModel(
      childMainAxisSize: childMainAxisSize,
      itemSeparatorHeight: itemSeparatorHeight,
      indexOfLine: indexOfLine,
      targetChildLayoutOffset: targetChildLayoutOffset,
    );
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

  /// Called when starting the scrolling task.
  _handleScrollStart({
    required BuildContext? context,
  }) {
    innerIsHandlingScroll = true;
    ObserverScrollStartNotification().dispatch(context);
  }

  /// Called when the scrolling task is interrupted.
  ///
  /// For example, the conditions are not met, or the item with the specified
  /// index cannot be found, etc.
  _handleScrollInterruption({
    required BuildContext? context,
    required Completer completer,
  }) {
    innerIsHandlingScroll = false;
    completer.complete();
    ObserverScrollInterruptionNotification().dispatch(context);
  }

  /// Called when the item with the specified index has been found.
  _handleScrollDecision({
    required BuildContext? context,
  }) {
    ObserverScrollDecisionNotification().dispatch(context);
  }

  /// Called after completing the scrolling task.
  _handleScrollEnd({
    required BuildContext? context,
    required Completer completer,
  }) {
    if (innerNeedOnceObserveCallBack != null) {
      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        innerIsHandlingScroll = false;
        innerNeedOnceObserveCallBack!();
        completer.complete();
        ObserverScrollEndNotification().dispatch(context);
      });
    } else {
      innerIsHandlingScroll = false;
      completer.complete();
      ObserverScrollEndNotification().dispatch(context);
    }
  }
}
