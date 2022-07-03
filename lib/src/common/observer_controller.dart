import 'package:flutter/material.dart';

class ObserverController {
  /// Target sliver [BuildContext]
  List<BuildContext> sliverContexts = [];

  /// Dispatch a observe notification
  innerDispatchOnceObserve({
    BuildContext? sliverContext,
    required Notification notification,
  }) {
    BuildContext? _sliverContext = fetchSliverContext(sliverContext);
    notification.dispatch(_sliverContext);
  }

  BuildContext? fetchSliverContext(BuildContext? sliverContext) {
    BuildContext? _sliverContext = sliverContext;
    if (_sliverContext == null && sliverContexts.isNotEmpty) {
      _sliverContext = sliverContexts.first;
    }
    return _sliverContext;
  }
}
