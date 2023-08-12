/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-12 16:01:29
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';

class ObserverHandleContextsResultModel<M extends ObserveModel> {
  /// Observation result for first sliver.
  /// Corresponding to [onObserve] in [ObserverWidget].
  final M? changeResultModel;

  /// Observation result map.
  /// Corresponding to [onObserveAll] in [ObserverWidget].
  final Map<BuildContext, M> changeResultMap;

  ObserverHandleContextsResultModel({
    this.changeResultModel,
    this.changeResultMap = const {},
  });
}
