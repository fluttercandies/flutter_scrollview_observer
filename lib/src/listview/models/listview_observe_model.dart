/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';

import 'listview_observe_displaying_child_model.dart';

class ListViewObserveModel extends ObserveModel {
  ListViewObserveModel({
    required this.sliverList,
    required RenderViewportBase viewport,
    required this.firstChild,
    required this.displayingChildModelList,
    required this.displayingChildModelMap,
    required bool visible,
  }) : super(
          visible: visible,
          sliver: sliverList,
          viewport: viewport,
          innerDisplayingChildModelList: displayingChildModelList,
          innerDisplayingChildModelMap: displayingChildModelMap,
        );

  /// The target sliverList.
  /// It would be [RenderSliverList] or [RenderSliverFixedExtentList].
  RenderSliverMultiBoxAdaptor sliverList;

  /// The observing data of the first child widget that is displaying.
  final ListViewObserveDisplayingChildModel? firstChild;

  /// Stores observing model list of displaying children widgets.
  final List<ListViewObserveDisplayingChildModel> displayingChildModelList;

  /// Stores observing model map of displaying children widgets.
  final Map<int, ListViewObserveDisplayingChildModel> displayingChildModelMap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ListViewObserveModel) {
      return firstChild == other.firstChild &&
          listEquals(
              displayingChildModelList, other.displayingChildModelList) &&
          mapEquals(displayingChildModelMap, other.displayingChildModelMap);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return firstChild.hashCode +
        displayingChildModelList.hashCode +
        displayingChildModelMap.hashCode;
  }
}
