/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-12-04 15:57:38
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/models/observe_scroll_to_index_result_model.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_viewport_observe_model.dart';

/// Called when the ObserverController prepare to scroll to index with
/// [ObservePrepareScrollToIndexModel].
typedef ObserverOnPrepareScrollToIndex = Future<bool> Function(
    ObservePrepareScrollToIndexModel);

/// The callback type of getting observed result for first sliver.
///
/// Corresponds to onObserve.
typedef OnObserveCallback<M extends ObserveModel> = void Function(
  M result,
);

/// The callback type of getting observed result map.
///
/// Corresponds to onObserveAll.
typedef OnObserveAllCallback<M extends ObserveModel> = void Function(
  Map<BuildContext, M> resultMap,
);

/// The callback type of getting all slivers those are displayed in viewport.
///
/// Corresponds to onObserveViewport.
typedef OnObserveViewportCallback = void Function(
  SliverViewportObserveModel result,
);

/// Define type that auto trigger observe.
enum ObserverAutoTriggerObserveType {
  scrollStart,
  scrollUpdate,
  scrollEnd,
}

/// Define type that trigger [onObserve] callback.
enum ObserverTriggerOnObserveType {
  directly,
  displayingItemsChange,
}

/// Define type of the observed render sliver.
enum ObserverRenderSliverType {
  /// listView
  list,

  /// gridView
  grid,
}
