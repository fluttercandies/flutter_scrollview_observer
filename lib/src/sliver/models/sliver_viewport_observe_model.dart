/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-13 22:36:22
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'sliver_viewport_observe_displaying_child_model.dart';

class SliverViewportObserveModel {
  /// The viewport of the current CustomScrollView.
  final RenderViewportBase viewport;

  /// The observing data of the first child widget that is displaying.
  final SliverViewportObserveDisplayingChildModel firstChild;

  /// Stores observing model list of displaying children widgets.
  final List<SliverViewportObserveDisplayingChildModel>
      displayingChildModelList;

  SliverViewportObserveModel({
    required this.viewport,
    required this.firstChild,
    required this.displayingChildModelList,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is SliverViewportObserveModel) {
      return viewport == other.viewport &&
          firstChild == other.firstChild &&
          listEquals(displayingChildModelList, other.displayingChildModelList);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return viewport.hashCode +
        firstChild.hashCode +
        displayingChildModelList.hashCode;
  }
}
