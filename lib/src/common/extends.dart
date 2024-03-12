/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-03-12 22:50:53
 */

import 'package:flutter/rendering.dart';

extension ObserverDouble on double {
  /// Rectify the value according to the current growthDirection of sliver.
  ///
  /// If the growthDirection is [GrowthDirection.forward], the value is
  /// returned directly, otherwise the opposite value is returned.
  double rectify(
    RenderSliverMultiBoxAdaptor obj,
  ) {
    return obj.isForwardGrowthDirection ? this : -this;
  }
}

extension ObserverRenderSliverMultiBoxAdaptor on RenderSliverMultiBoxAdaptor {
  /// Determine whether the current growthDirection of sliver is
  /// [GrowthDirection.forward].
  bool get isForwardGrowthDirection {
    return GrowthDirection.forward == constraints.growthDirection;
  }
}
