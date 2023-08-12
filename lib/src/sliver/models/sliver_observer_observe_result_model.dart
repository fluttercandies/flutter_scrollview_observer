/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-12 16:18:26
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_viewport_observe_model.dart';

class SliverObserverHandleContextsResultModel<M extends ObserveModel>
    extends ObserverHandleContextsResultModel {
  /// Getting all slivers those are displayed in viewport.
  ///
  /// Corresponding to [onObserveViewport] in [SliverViewObserver].
  final SliverViewportObserveModel? observeViewportResultModel;

  SliverObserverHandleContextsResultModel({
    M? changeResultModel,
    Map<BuildContext, M> changeResultMap = const {},
    this.observeViewportResultModel,
  }) : super(
          changeResultModel: changeResultModel,
          changeResultMap: changeResultMap,
        );
}
