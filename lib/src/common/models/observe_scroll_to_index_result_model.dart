/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-25 21:29:37
 */

import 'package:flutter/rendering.dart';

class ObserveScrollToIndexFixedHeightResultModel {
  /// The size of item on the main axis.
  double childMainAxisSize;

  /// The separator size between items on the main axis.
  double itemSeparatorHeight;

  /// The number of rows for the target item.
  int indexOfLine;

  /// The offset of the target child widget on the main axis.
  double targetChildLayoutOffset;

  ObserveScrollToIndexFixedHeightResultModel({
    required this.childMainAxisSize,
    required this.itemSeparatorHeight,
    required this.indexOfLine,
    required this.targetChildLayoutOffset,
  });
}

class ObservePrepareScrollToIndexModel {
  /// The scroll distance that has been consumed by all [RenderSliver]s that
  /// came before this [RenderSliver].
  double precedingScrollExtent;

  /// The target safety layout offset for scrolling to index.
  double calculateTargetLayoutOffset;

  /// The offset of the target child widget on the main axis.
  double targetChildLayoutOffset;

  ObservePrepareScrollToIndexModel({
    required this.calculateTargetLayoutOffset,
    required this.precedingScrollExtent,
    required this.targetChildLayoutOffset,
  });
}
