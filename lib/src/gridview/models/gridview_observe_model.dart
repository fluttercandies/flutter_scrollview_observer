import 'package:flutter/foundation.dart';

import 'gridview_observe_displaying_child_model.dart';

class GridViewObserveModel {
  /// Whether this sliver should be painted.
  final bool visible;

  /// The first group child widgets those are displaying.
  final List<GridViewObserveDisplayingChildModel> firstGroupChildList;

  /// Stores model list for children widgets those are displaying.
  final List<GridViewObserveDisplayingChildModel> displayingChildModelList;

  /// Stores index list for children widgets those are displaying.
  List<int> get displayingChildIndexList =>
      displayingChildModelList.map((e) => e.index).toList();

  GridViewObserveModel({
    required this.visible,
    required this.firstGroupChildList,
    required this.displayingChildModelList,
  });

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
