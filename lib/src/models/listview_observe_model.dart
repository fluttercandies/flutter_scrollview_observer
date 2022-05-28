import 'package:flutter/foundation.dart';

import 'listview_observe_displaying_child_model.dart';

class ListViewObserveModel {
  /// 目标子组件的下标
  final ListViewObserveDisplayingChildModel firstChild;

  /// 正在显示的子组件的renderObject
  final List<ListViewObserveDisplayingChildModel> showingChildModelList;

  /// 正在显示的子组件的下标集
  List<int> get showingChildIndexList =>
      showingChildModelList.map((e) => e.index).toList();

  ListViewObserveModel({
    required this.firstChild,
    required this.showingChildModelList,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ListViewObserveModel) {
      return firstChild == other.firstChild &&
          listEquals(showingChildModelList, other.showingChildModelList);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return firstChild.hashCode + showingChildModelList.hashCode;
  }
}
