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
