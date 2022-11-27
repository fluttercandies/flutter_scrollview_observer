import 'package:flutter/material.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

class ObserverIndexPositionModel {
  ObserverIndexPositionModel({
    required this.index,
    this.sliverContext,
    this.isFixedHeight = false,
    this.alignment = 0,
    this.offset,
  });

  /// The index position of the scrollView.
  int index;

  /// The target sliver [BuildContext].
  BuildContext? sliverContext;

  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass [true] to this property.
  bool isFixedHeight;

  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget.
  ///
  /// It must be a value in the range [0.0, 1.0].
  double alignment;

  /// Use this property when locating position needs an offset.
  ObserverLocateIndexOffsetCallback? offset;
}
