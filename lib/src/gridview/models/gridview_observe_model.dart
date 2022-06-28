import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';

import 'gridview_observe_displaying_child_model.dart';

class GridViewObserveModel extends ObserveModel {
  GridViewObserveModel({
    required this.sliverGrid,
    required this.firstGroupChildList,
    required this.displayingChildModelList,
    required bool visible,
  }) : super(
          visible: visible,
          sliver: sliverGrid,
          innerDisplayingChildModelList: displayingChildModelList,
        );

  /// The target sliverGrid
  RenderSliverGrid sliverGrid;

  /// The first group child widgets those are displaying.
  final List<GridViewObserveDisplayingChildModel> firstGroupChildList;

  /// Stores model list for children widgets those are displaying.
  final List<GridViewObserveDisplayingChildModel> displayingChildModelList;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GridViewObserveModel) {
      return listEquals(firstGroupChildList, other.firstGroupChildList) &&
          listEquals(displayingChildModelList, other.displayingChildModelList);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return firstGroupChildList.hashCode + displayingChildModelList.hashCode;
  }
}
