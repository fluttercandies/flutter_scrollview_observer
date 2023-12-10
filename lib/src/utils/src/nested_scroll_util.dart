/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-12-04 20:15:33
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class NestedScrollUtil {
  /// Record the [BuildContext] corresponding to all header slivers of
  /// NestedScrollView.
  List<BuildContext> headerSliverContexts = [];

  /// Record the [BuildContext] corresponding to all body slivers of
  /// NestedScrollView.
  List<BuildContext> bodySliverContexts = [];

  /// Record the [BuildContext] of [SliverFillRemaining].
  BuildContext? remainingSliverContext;

  /// Record the [RenderObject] of [SliverFillRemaining].
  RenderSliverSingleBoxAdapter? remainingSliverRenderObj;

  /// Calculate the overlap for the body sliver.
  double? calcOverlap({
    required GlobalKey nestedScrollViewKey,
    required BuildContext sliverContext,
  }) {
    final nestedScrollViewCtx = nestedScrollViewKey.currentContext;
    if (nestedScrollViewCtx == null) return null;

    // If the sliver of ctx is headerSliver, just return null and use the
    // default overlap.
    if (!bodySliverContexts.contains(sliverContext)) return null;

    // Get SliverFillRemaining
    final remainingSliverContext = fetchRemainingSliverContext(
      nestedScrollViewKey: nestedScrollViewKey,
    );
    if (remainingSliverContext == null || remainingSliverRenderObj == null) {
      return null;
    }

    /// Calculate the offset of the sliver corresponding to sliverContext
    /// relative to SliverFillRemaining.
    final offset = ObserverUtils.localToGlobal(
      context: sliverContext,
      point: Offset.zero,
      ancestor: remainingSliverContext,
    );
    if (offset == null) return null;

    final remainingContextOverlap =
        remainingSliverRenderObj!.constraints.overlap;
    final sliverContextExtraOverlap =
        (remainingContextOverlap - offset.dy).clamp(0, double.infinity);

    var _obj = ObserverUtils.findRenderObject(sliverContext);
    if (_obj is! RenderSliverMultiBoxAdaptor) return null;
    return sliverContextExtraOverlap + _obj.constraints.overlap;
  }

  double? calcPrecedingScrollExtent({
    required GlobalKey nestedScrollViewKey,
    required BuildContext sliverContext,
  }) {
    double precedingScrollExtent = 0;
    var _obj = ObserverUtils.findRenderObject(sliverContext);
    if (_obj is! RenderSliverMultiBoxAdaptor) return null;
    precedingScrollExtent = _obj.constraints.precedingScrollExtent;

    // Get SliverFillRemaining
    final remainingSliverContext = fetchRemainingSliverContext(
      nestedScrollViewKey: nestedScrollViewKey,
    );
    if (remainingSliverContext == null || remainingSliverRenderObj == null) {
      return null;
    }
    precedingScrollExtent +=
        remainingSliverRenderObj?.constraints.precedingScrollExtent ?? 0;
    return precedingScrollExtent;
  }

  /// Reset all data.
  reset() {
    headerSliverContexts.clear();
    bodySliverContexts.clear();
    remainingSliverContext = null;
    remainingSliverRenderObj = null;
  }

  /// Get SliverFillRemaining
  BuildContext? fetchRemainingSliverContext({
    required GlobalKey nestedScrollViewKey,
  }) {
    // Find out SliverFillRemaining
    final nestedScrollViewCtx = nestedScrollViewKey.currentContext;
    if (nestedScrollViewCtx == null) return null;
    remainingSliverContext ??= ObserverUtils.findChildContext(
      context: nestedScrollViewCtx,
      isTargetType: (ctx) {
        final obj = ctx.findRenderObject();
        if (obj is RenderSliverSingleBoxAdapter) {
          remainingSliverRenderObj = obj;
          return true;
        }
        return false;
      },
    );
    return remainingSliverContext;
  }
}
