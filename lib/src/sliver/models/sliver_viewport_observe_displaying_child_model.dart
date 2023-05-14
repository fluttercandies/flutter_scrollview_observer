/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-14 10:51:42
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverViewportObserveDisplayingChildModel {
  /// The [BuildContext] object for the [sliver].
  final BuildContext sliverContext;

  /// The [sliver] displayed in the current CustomScrollView.
  final RenderSliver sliver;

  SliverViewportObserveDisplayingChildModel({
    required this.sliverContext,
    required this.sliver,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is SliverViewportObserveDisplayingChildModel) {
      return sliverContext == other.sliverContext && sliver == other.sliver;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return sliverContext.hashCode + sliver.hashCode;
  }
}
