import 'package:flutter/foundation.dart';

import 'listview_observe_displaying_child_model.dart';

class ListViewObserveModel {
  /// The first child widget that is displaying.
  final ListViewObserveDisplayingChildModel firstChild;

  /// Stores model list for children widgets those are displaying.
  final List<ListViewObserveDisplayingChildModel> displayingChildModelList;

  /// Stores index list for children widgets those are displaying.
  List<int> get displayingChildIndexList =>
      displayingChildModelList.map((e) => e.index).toList();

  ListViewObserveModel({
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
