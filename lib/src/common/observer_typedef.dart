/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-12-04 15:57:38
 */

import 'package:scrollview_observer/src/common/models/observe_scroll_to_index_result_model.dart';

/// Called when the ObserverController prepare to scroll to index with
/// [ObservePrepareScrollToIndexModel].
typedef ObserverOnPrepareScrollToIndex = Future<bool> Function(
    ObservePrepareScrollToIndexModel);

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
