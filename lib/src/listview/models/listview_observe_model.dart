import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'listview_observe_displaying_child_model.dart';

class ListViewObserveModel {
  /// Whether this sliver should be painted.
  final bool visible;

  /// The target sliverList
  RenderSliverList sliverList;

  /// The first child widget that is displaying.
  final ListViewObserveDisplayingChildModel? firstChild;

  /// Stores model list for children widgets those are displaying.
  final List<ListViewObserveDisplayingChildModel> displayingChildModelList;

  /// Stores index list for children widgets those are displaying.
  List<int> get displayingChildIndexList =>
      displayingChildModelList.map((e) => e.index).toList();

  /// The axis of sliverList
  Axis get axis => sliverList.constraints.axis;

  /// The scroll offset of sliverList
  double get scrollOffset => sliverList.constraints.scrollOffset;

  ListViewObserveModel({
    required this.sliverList,
    required this.visible,
    required this.firstChild,
    required this.displayingChildModelList,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ListViewObserveModel) {
      return firstChild == other.firstChild &&
          listEquals(displayingChildModelList, other.displayingChildModelList);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return firstChild.hashCode + displayingChildModelList.hashCode;
  }
}
