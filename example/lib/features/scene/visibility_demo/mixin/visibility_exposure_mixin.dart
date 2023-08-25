import 'package:scrollview_observer/scrollview_observer.dart';

mixin VisibilityExposureMixin {
  // Exposure record
  Map<dynamic, bool> exposureRecordMap = {};

  /// Reset exposure record
  resetExposureRecordMap() {
    exposureRecordMap.clear();
  }

  /// Handling the exposure logic of ScrollView item
  ///
  /// [resultModel] Observation result (the super class is ObserveModel,
  /// pass the value obtained in the onObserve callback, or the value obtained
  /// according to BuildContext in onObserveAll).
  /// [toExposeDisplayPercent] When the self-display ratio exceeds this value,
  /// it is regarded as exposure and recorded, otherwise the exposure record
  /// is reset.
  /// [recordKeyCallback] Return the key used to record the exposure, if not
  /// implemented, use index as the key.
  /// [needExposeCallback] Whether to participate in the callback of exposure
  /// calculation.
  /// [toExposeCallback] Callback for exposure conditions met.
  handleExposure({
    required dynamic resultModel,
    double toExposeDisplayPercent = 0.5,
    dynamic Function(int index)? recordKeyCallback,
    bool Function(int index)? needExposeCallback,
    required Function(int index) toExposeCallback,
  }) {
    List<ObserveDisplayingChildModelMixin> displayingChildModelList = [];
    if (resultModel is ListViewObserveModel) {
      displayingChildModelList = resultModel.displayingChildModelList;
    } else if (resultModel is GridViewObserveModel) {
      displayingChildModelList = resultModel.displayingChildModelList;
    }
    for (var displayingChildModel in displayingChildModelList) {
      final index = displayingChildModel.index;
      final recordKey = recordKeyCallback?.call(index) ?? index;
      // By letting the outside tell us whether ScrollView item need to
      // participate in the exposure calculation logic
      final needExpose = needExposeCallback?.call(index) ?? true;
      if (!needExpose) continue;
      // debugPrint('item : $index - ${displayingChildModel.displayPercentage}');
      // Determine whether the percentage displayed by the item exceeds
      // [toExposeDisplayPercent]
      if (displayingChildModel.displayPercentage < toExposeDisplayPercent) {
        // Does not meet the exposure conditions, reset exposure record
        exposureRecordMap[recordKey] = false;
      } else {
        // Meet the exposure conditions
        final haveExposure = exposureRecordMap[recordKey] ?? false;
        if (haveExposure) continue;
        toExposeCallback(index);
        exposureRecordMap[recordKey] = true;
      }
    }
  }
}
