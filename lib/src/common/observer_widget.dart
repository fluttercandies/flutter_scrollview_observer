import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

import 'models/observe_model.dart';

class ObserverWidget<C extends ObserverController, M extends ObserveModel,
    N extends Notification, S extends RenderSliver> extends StatefulWidget {
  final Widget child;

  /// An object that can be used to dispatch a [ListViewOnceObserveNotification]
  /// or [GridViewOnceObserveNotification].
  final C? sliverController;

  /// The callback of getting all sliver's buildContext.
  final List<BuildContext> Function()? sliverContexts;

  /// The callback of geting observed result map.
  final Function(Map<BuildContext, M>)? onObserveAll;

  /// The callback of geting observed result for first listView.
  final Function(M)? onObserve;

  /// Calculate offset.
  final double leadingOffset;

  /// Calculate offset dynamically
  /// If this callback is implemented, the [leadingOffset] property will be
  /// invalid.
  final double Function()? dynamicLeadingOffset;

  /// After the internal logic figure out the first child widget, if the
  /// proportion of the size of the child widget blocked to its own size exceeds
  /// the value [toNextOverPercent], the next child widget will be the first
  /// child widget.
  final double toNextOverPercent;

  const ObserverWidget({
    Key? key,
    required this.child,
    this.sliverController,
    this.sliverContexts,
    this.onObserveAll,
    this.onObserve,
    this.leadingOffset = 0,
    this.dynamicLeadingOffset,
    this.toNextOverPercent = 1,
  })  : assert(toNextOverPercent > 0 && toNextOverPercent <= 1),
        super(key: key);

  @override
  State<ObserverWidget> createState() =>
      ObserverWidgetState<C, M, N, S, ObserverWidget<C, M, N, S>>();
}

class ObserverWidgetState<
    C extends ObserverController,
    M extends ObserveModel,
    N extends Notification,
    S extends RenderSliver,
    T extends ObserverWidget<C, M, N, S>> extends State<T> {
  /// Target sliver [BuildContext]
  List<BuildContext> targetSliverContexts = [];

  /// The last observation result
  Map<BuildContext, M> lastResultMap = {};

  @override
  void initState() {
    super.initState();
    _setupSliverController();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<N>(
      onNotification: (_) {
        _handleContexts();
        return true;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleContexts();
          return false;
        },
        child: widget.child,
      ),
    );
  }

  /// Setup sliver controller
  _setupSliverController() {
    final sliverController = widget.sliverController;
    if (sliverController == null) return;
    sliverController.innerReset();
    sliverController.innerNeedOnceObserveCallBack = () {
      _handleContexts();
    };
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      targetSliverContexts = fetchTargetSliverContexts();
      sliverController.sliverContexts = targetSliverContexts;
    });
  }

  /// Featch target sliver [BuildContext]s
  List<BuildContext> fetchTargetSliverContexts() {
    List<BuildContext> ctxs = targetSliverContexts;
    if (ctxs.isEmpty) {
      final sliverListContexts = widget.sliverContexts;
      if (sliverListContexts != null) {
        ctxs = sliverListContexts();
      } else {
        List<BuildContext> _ctxs = [];
        void visitor(Element element) {
          if (element.renderObject is S) {
            /// Find the target sliver context
            _ctxs.add(element);
            return;
          }
          element.visitChildren(visitor);
        }

        context.visitChildElements(visitor);
        ctxs = _ctxs;
      }
    }
    return ctxs;
  }

  /// Handle all buildContext
  _handleContexts() {
    final onObserve = widget.onObserve;
    final onObserveAll = widget.onObserveAll;
    if (onObserve == null && onObserveAll == null) return;

    final isHandlingScroll =
        widget.sliverController?.innerIsHandlingScroll ?? false;
    if (isHandlingScroll) return;

    List<BuildContext> ctxs = fetchTargetSliverContexts();

    Map<BuildContext, M> resultMap = {};
    Map<BuildContext, M> changeResultMap = {};
    M? changeResultModel;
    for (var i = 0; i < ctxs.length; i++) {
      final ctx = ctxs[i];
      final targetObserveModel = handleObserve(ctx);
      if (targetObserveModel == null) continue;
      resultMap[ctx] = targetObserveModel;

      final lastResultModel = lastResultMap[ctx];
      if (lastResultModel == null) {
        changeResultMap[ctx] = targetObserveModel;
      } else if (lastResultModel != targetObserveModel) {
        changeResultMap[ctx] = targetObserveModel;
      }

      // Geting observed result for first listView
      if (i == 0 && changeResultMap[ctx] != null) {
        changeResultModel = changeResultMap[ctx];
      }
    }

    lastResultMap = resultMap;

    if (onObserve != null && changeResultModel != null) {
      onObserve(changeResultModel);
    }

    if (onObserveAll != null && changeResultMap.isNotEmpty) {
      onObserveAll(changeResultMap);
    }
  }

  M? handleObserve(BuildContext ctx) {
    return null;
  }

  /// Determines whether the target child widget is the first widget being
  /// displayed
  bool isTargetFirstWidget({
    required double listViewOffset,
    required Axis scrollDirection,
    required RenderBox targetFirstChild,
  }) {
    if (targetFirstChild is! RenderIndexedSemantics) return false;
    final parentData = targetFirstChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetFirstChildOffset = parentData.layoutOffset ?? 0;
    final targetFirstChildSize = scrollDirection == Axis.vertical
        ? targetFirstChild.size.height
        : targetFirstChild.size.width;
    return listViewOffset <
        targetFirstChildSize * widget.toNextOverPercent +
            targetFirstChildOffset;
  }

  /// Determines whether the target child widget is being displayed
  bool isDisplayingChild({
    required RenderBox? targetChild,
    required double listViewBottomOffset,
  }) {
    if (targetChild == null) {
      return false;
    }
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetChildLayoutOffset = parentData.layoutOffset ?? 0;
    return targetChildLayoutOffset < listViewBottomOffset;
  }
}
