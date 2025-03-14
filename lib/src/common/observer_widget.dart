/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/observer_listener.dart';
import 'package:scrollview_observer/src/common/observer_typedef.dart';
import 'package:scrollview_observer/src/common/observer_widget_scope.dart';
import 'package:scrollview_observer/src/common/observer_widget_tag_manager.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';
import 'package:scrollview_observer/src/notification.dart';
import 'package:scrollview_observer/src/utils/src/log.dart';

import 'models/observe_model.dart';

class ObserverWidget<C extends ObserverController, M extends ObserveModel,
    N extends ScrollViewOnceObserveNotification> extends StatefulWidget {
  /// The subtree below this widget.
  final Widget child;

  /// This is for when you have multiple nested [ObserverWidget] widgets and
  /// you want to get the corresponding [ObserverWidgetState].
  ///
  /// It must be a unique string in the tree.
  final String? tag;

  /// An object that can be used to dispatch a [ListViewOnceObserveNotification]
  /// or [GridViewOnceObserveNotification].
  final C? sliverController;

  /// The callback of getting all sliver's buildContext.
  final List<BuildContext> Function()? sliverContexts;

  /// The callback of getting observed result map.
  final OnObserveAllCallback<M>? onObserveAll;

  /// The callback of getting observed result for first sliver.
  final OnObserveCallback<M>? onObserve;

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

  /// A predicate for [ScrollNotification], used to determine whether
  /// observation can be triggered.
  ///
  /// Generally combined with [defaultScrollNotificationPredicate] to check
  /// whether `notification.depth == 0`, which means that the notification did
  /// not bubble through any intervening scrolling widgets.
  /// This can avoid the unnecessary observation calculations caused by
  /// intervening scrolling widgets, which in turn improves performance.
  final ScrollNotificationPredicate? scrollNotificationPredicate;

  /// Used to set types those can trigger observe automatically.
  ///
  /// Defaults to [.scrollStart, .scrollUpdate, .scrollEnd]
  final List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes;

  /// Used to set the prerequisite for triggering the [onObserve] callback.
  ///
  /// Defaults to [ObserverTriggerOnObserveType.displayingItemsChange].
  final ObserverTriggerOnObserveType triggerOnObserveType;

  /// Used to find the target RenderSliver.
  ///
  /// The default is to find [RenderSliverList], [RenderSliverFixedExtentList]
  /// and [RenderSliverGrid].
  final bool Function(RenderObject?)? customTargetRenderSliverType;

  /// It allows you to customize observation logic when original logic doesn't
  /// fit your needs.
  final M? Function(BuildContext)? customHandleObserve;

  const ObserverWidget({
    Key? key,
    required this.child,
    this.tag,
    this.sliverController,
    this.sliverContexts,
    this.onObserveAll,
    this.onObserve,
    this.leadingOffset = 0,
    this.dynamicLeadingOffset,
    this.toNextOverPercent = 1,
    this.scrollNotificationPredicate,
    this.autoTriggerObserveTypes,
    this.triggerOnObserveType =
        ObserverTriggerOnObserveType.displayingItemsChange,
    this.customHandleObserve,
    this.customTargetRenderSliverType,
  })  : assert(toNextOverPercent > 0 && toNextOverPercent <= 1),
        super(key: key);

  @override
  State<ObserverWidget> createState() =>
      ObserverWidgetState<C, M, N, ObserverWidget<C, M, N>>();

  /// Returning the closest instance of this class that encloses the given
  /// context.
  ///
  /// If you give a tag, it will give priority find the corresponding instance
  /// of this class with the given tag and return it.
  ///
  /// If there is no [ObserverWidget] widget, then null is returned.
  ///
  /// Calling this method will create a dependency on the closest
  /// [ObserverWidget] in the [context], if there is one.
  ///
  /// See also:
  ///
  /// * [ObserverWidget.of], which is similar to this method, but asserts if no
  ///   [ObserverWidget] instance is found.
  static ObserverWidgetState<C, M, N, T>? maybeOf<
      C extends ObserverController,
      M extends ObserveModel,
      N extends ScrollViewOnceObserveNotification,
      T extends ObserverWidget<C, M, N>>(
    BuildContext context, {
    String? tag,
  }) {
    BuildContext? _ctx;
    if (tag != null) {
      final tagManager = ObserverWidgetTagManager.maybeOf(context);
      _ctx = tagManager?.context(tag);
    }
    return (_ctx ?? context)
        .dependOnInheritedWidgetOfExactType<ObserverWidgetScope<C, M, N, T>>()
        ?.observerWidgetState;
  }

  /// Returning the closest instance of this class that encloses the given
  /// context.
  ///
  /// If you give a tag, it will give priority find the corresponding instance
  /// of this class with the given tag and return it.
  ///
  /// If no instance is found, this method will assert in debug mode, and throw
  /// an exception in release mode.
  ///
  /// Calling this method will create a dependency on the closest
  /// [ObserverWidget] in the [context].
  ///
  /// See also:
  ///
  /// * [ObserverWidget.maybeOf], which is similar to this method, but returns
  ///   null if no [ObserverWidget] instance is found.
  static ObserverWidgetState<C, M, N, T> of<
      C extends ObserverController,
      M extends ObserveModel,
      N extends ScrollViewOnceObserveNotification,
      T extends ObserverWidget<C, M, N>>(
    BuildContext context, {
    String? tag,
  }) {
    final observerState = maybeOf<C, M, N, T>(
      context,
      tag: tag,
    );
    assert(() {
      if (observerState == null) {
        throw FlutterError(
          '$T.of() was called with a context that does not contain a '
          '$T widget.\n'
          'No $T widget ancestor could be found starting from the '
          'context that was passed to $T.of(). This can happen '
          'because you are using a widget that looks for a $T '
          'ancestor, but no such ancestor exists.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return observerState!;
  }
}

class ObserverWidgetState<
    C extends ObserverController,
    M extends ObserveModel,
    N extends ScrollViewOnceObserveNotification,
    T extends ObserverWidget<C, M, N>> extends State<T> {
  /// Target sliver [BuildContext]
  List<BuildContext> targetSliverContexts = [];

  /// The last observation result
  Map<BuildContext, M> lastResultMap = {};

  /// Default values for the widget's autoTriggerObserveTypes property.
  List<ObserverAutoTriggerObserveType> get innerAutoTriggerObserveTypes =>
      widget.autoTriggerObserveTypes ??
      [
        ObserverAutoTriggerObserveType.scrollStart,
        ObserverAutoTriggerObserveType.scrollUpdate,
        ObserverAutoTriggerObserveType.scrollEnd
      ];

  /// Mapping [ObserverAutoTriggerObserveType] to [ScrollNotification].
  List<Type> get innerAutoTriggerObserveScrollNotifications =>
      innerAutoTriggerObserveTypes.map((type) {
        switch (type) {
          case ObserverAutoTriggerObserveType.scrollStart:
            return ScrollStartNotification;
          case ObserverAutoTriggerObserveType.scrollUpdate:
            return ScrollUpdateNotification;
          case ObserverAutoTriggerObserveType.scrollEnd:
            return ScrollEndNotification;
        }
      }).toList();

  /// Whether can handle observe.
  bool innerCanHandleObserve = true;

  /// The [BuildContext] of the [ObserverWidgetScope].
  BuildContext? scopeContext;

  /// The listener list state for a [ObserverWidget] returned by
  /// [ObserverWidget.of].
  ///
  /// It supports a listener list instead of just a single observation
  /// callback (such as onObserve and onObserveAll).
  @protected
  @visibleForTesting
  LinkedList<ObserverListenerEntry<M>>? innerListeners =
      LinkedList<ObserverListenerEntry<M>>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (innerListeners == null) {
        throw FlutterError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }

  @override
  void initState() {
    super.initState();
    _setupSliverController(isInitState: true);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    _checkTagChange(oldWidget);
  }

  @override
  void dispose() {
    assert(_debugAssertNotDisposed());
    innerListeners?.clear();
    innerListeners = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Placed at the deepest level for convenient subsequent operations using
    // its context.
    Widget resultWidget = ObserverWidgetScope<C, M, N, T>(
      child: widget.child,
      observerWidgetState: this,
      onCreateElement: _handleScopeContext,
    );
    resultWidget = NotificationListener<N>(
      onNotification: (notification) {
        final result = handleContexts(
          isForceObserve: notification.isForce,
          isFromObserveNotification: true,
          isDependObserveCallback: notification.isDependObserveCallback,
        );
        final sliverController = widget.sliverController;
        if (sliverController is ObserverControllerForNotification) {
          sliverController.innerHandleDispatchOnceObserveComplete(
            resultModel: result,
          );
        }
        return true;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // If the scrollNotificationPredicate returns false, the notification
          // will be ignored.
          if (!(widget.scrollNotificationPredicate?.call(notification) ??
              true)) {
            return false;
          }
          // If the notification.runtimeType is not in the list of
          // innerAutoTriggerObserveScrollNotifications that can trigger
          // observation, the notification will be ignored.
          if (innerAutoTriggerObserveScrollNotifications
              .contains(notification.runtimeType)) {
            final isIgnoreInnerCanHandleObserve =
                ScrollUpdateNotification != notification.runtimeType;
            WidgetsBinding.instance.endOfFrame.then((_) {
              // Need to wait for frame end to avoid inaccurate observation
              // result, reasons as follows
              //
              // ======================== WEB ========================
              //
              // Getting bad observation result because scrolling in Flutter Web
              // with mouse wheel is not smooth.
              // https://github.com/flutter/flutter/issues/78708
              // https://github.com/flutter/flutter/issues/78634
              //
              // issue
              // https://github.com/LinXunFeng/flutter_scrollview_observer/issues/31
              //
              // ======================== APP ========================
              //
              // When using ScrollController's animateTo with a value exceeding
              // the maximum scroll range, it will lead to inaccurate
              // observation result.
              //
              // issue
              // https://github.com/fluttercandies/flutter_scrollview_observer/issues/113
              handleContexts(
                isIgnoreInnerCanHandleObserve: isIgnoreInnerCanHandleObserve,
              );
            });
          }
          return false;
        },
        child: resultWidget,
      ),
    );
    // When nesting multiple ObserverWidgets, ensure that only one
    // ObserverWidgetTagManager is at the top.
    if (ObserverWidgetTagManager.maybeOf(context) == null) {
      resultWidget = ObserverWidgetTagManager(
        child: resultWidget,
      );
    }
    return resultWidget;
  }

  /// Setup sliver controller
  _setupSliverController({bool isInitState = false}) {
    final sliverController = widget.sliverController;
    if (sliverController == null) return;
    sliverController.innerReset();
    sliverController.innerNeedOnceObserveCallBack = () {
      handleContexts();
    };
    sliverController.innerReattachCallBack = () {
      targetSliverContexts.clear();
      _setupSliverController();
    };
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      targetSliverContexts = fetchTargetSliverContexts();
      sliverController.sliverContexts = targetSliverContexts;
      if (isInitState && sliverController is ObserverControllerForScroll) {
        sliverController.innerInitialIndexPosition();
      }
    });
  }

  /// Fetch target sliver [BuildContext]s
  List<BuildContext> fetchTargetSliverContexts() {
    List<BuildContext> ctxs = targetSliverContexts;
    if (ctxs.isEmpty) {
      final sliverListContexts = widget.sliverContexts;
      if (sliverListContexts != null) {
        ctxs = sliverListContexts();
      } else {
        List<BuildContext> _ctxs = [];
        void visitor(Element element) {
          if (isTargetSliverContextType(element.renderObject)) {
            /// Find the target sliver context
            _ctxs.add(element);
            return;
          }
          element.visitChildren(visitor);
        }

        try {
          // https://github.com/LinXunFeng/flutter_scrollview_observer/issues/35
          context.visitChildElements(visitor);
        } catch (e) {
          Log.warning(
            'This widget has been unmounted, so the State no longer has a context (and should be considered defunct). \n'
            'Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.',
          );
        }

        ctxs = _ctxs;
      }
    }
    return ctxs;
  }

  /// Fetch offset from [leadingOffset] or [dynamicLeadingOffset].
  double fetchLeadingOffset() {
    var offset = widget.leadingOffset;
    if (widget.dynamicLeadingOffset != null) {
      offset = widget.dynamicLeadingOffset!();
    }
    return offset;
  }

  /// Determine whether it is the type of the target sliver.
  bool isTargetSliverContextType(RenderObject? obj) {
    if (widget.customTargetRenderSliverType != null) {
      return widget.customTargetRenderSliverType!.call(obj);
    }
    return obj is RenderSliverList;
  }

  /// Update [innerCanHandleObserve] according to the
  /// [ObserverController.observeIntervalForScrolling].
  updateInnerCanHandleObserve() async {
    final observeInterval =
        widget.sliverController?.observeIntervalForScrolling ?? Duration.zero;
    if (Duration.zero == observeInterval) {
      innerCanHandleObserve = true;
      return;
    }
    if (!innerCanHandleObserve) return;
    innerCanHandleObserve = false;
    await Future.delayed(observeInterval);
    innerCanHandleObserve = true;
  }

  /// Handle all buildContext
  ObserverHandleContextsResultModel<M>? handleContexts({
    bool isForceObserve = false,
    bool isFromObserveNotification = false,
    bool isDependObserveCallback = true,
    bool isIgnoreInnerCanHandleObserve = true,
  }) {
    if (!isIgnoreInnerCanHandleObserve) {
      if (!innerCanHandleObserve) {
        return null;
      }
      updateInnerCanHandleObserve();
    }

    final isForbidObserveCallback =
        widget.sliverController?.isForbidObserveCallback ?? false;
    final onObserve = isForbidObserveCallback ? null : widget.onObserve;
    final onObserveAll = isForbidObserveCallback ? null : widget.onObserveAll;
    if (isDependObserveCallback) {
      if (onObserve == null &&
          onObserveAll == null &&
          (innerListeners?.isEmpty ?? true)) {
        return null;
      }
    }

    final isHandlingScroll =
        widget.sliverController?.innerIsHandlingScroll ?? false;
    if (isHandlingScroll) {
      return null;
    }

    List<BuildContext> ctxs = fetchTargetSliverContexts();

    Map<BuildContext, M> resultMap = {};
    Map<BuildContext, M> changeResultMap = {};
    M? changeResultModel;
    for (var i = 0; i < ctxs.length; i++) {
      final ctx = ctxs[i];
      final targetObserveModel = handleObserve(ctx);
      if (targetObserveModel == null) continue;
      resultMap[ctx] = targetObserveModel;

      if (isForceObserve ||
          widget.triggerOnObserveType ==
              ObserverTriggerOnObserveType.directly) {
        changeResultMap[ctx] = targetObserveModel;
      } else {
        final lastResultModel = lastResultMap[ctx];
        if (lastResultModel == null) {
          changeResultMap[ctx] = targetObserveModel;
        } else if (lastResultModel != targetObserveModel) {
          changeResultMap[ctx] = targetObserveModel;
        }
      }

      // Getting observed result for first listView.
      if (i == 0 && changeResultMap[ctx] != null) {
        changeResultModel = changeResultMap[ctx];
      }
    }

    lastResultMap = resultMap;

    if (isDependObserveCallback &&
        onObserve != null &&
        changeResultModel != null) {
      onObserve(changeResultModel);
    }

    if (isDependObserveCallback &&
        onObserveAll != null &&
        changeResultMap.isNotEmpty) {
      onObserveAll(changeResultMap);
    }

    _notifyListeners(changeResultMap);

    return ObserverHandleContextsResultModel(
      changeResultModel: changeResultModel,
      changeResultMap: changeResultMap,
    );
  }

  M? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return null;
  }

  void _handleScopeContext(BuildContext ctx) async {
    scopeContext = ctx;
    final tag = widget.tag ?? '';
    if (tag.isEmpty) return;
    await WidgetsBinding.instance.endOfFrame;
    assert(ctx.mounted);
    final tagManager = ObserverWidgetTagManager.maybeOf(ctx);
    tagManager?.set(tag, ctx);
  }

  void _checkTagChange(T oldWidget) async {
    final oldTag = oldWidget.tag ?? '';
    final tag = widget.tag ?? '';
    if (tag == oldWidget) return;
    // Execute after the current frame ends to avoid getting an outdated
    // ObserverWidgetTagManager.
    await WidgetsBinding.instance.endOfFrame;
    final _scopeContext = scopeContext;
    if (_scopeContext == null) return;
    assert(_scopeContext.mounted);
    final tagManager = ObserverWidgetTagManager.maybeOf(_scopeContext);
    tagManager?.remove(oldTag);
    if (tag.isNotEmpty) {
      tagManager?.set(tag, _scopeContext);
    }
  }

  /// Add [OnObserveCallback] and [OnObserveAllCallback] that will be called
  /// each time a result is observed.
  void addListener({
    BuildContext? context,
    OnObserveCallback<M>? onObserve,
    OnObserveAllCallback<M>? onObserveAll,
  }) {
    assert(_debugAssertNotDisposed());
    assert(
      onObserve != null || onObserveAll != null,
      'At least one callback must be provided.',
    );
    innerListeners?.add(ObserverListenerEntry<M>(
      context: context,
      onObserve: onObserve,
      onObserveAll: onObserveAll,
    ));
  }

  /// Remove the specified [OnObserveCallback] and [OnObserveAllCallback].
  void removeListener({
    BuildContext? context,
    OnObserveCallback<M>? onObserve,
    OnObserveAllCallback<M>? onObserveAll,
  }) {
    assert(_debugAssertNotDisposed());
    assert(
      onObserve != null || onObserveAll != null,
      'At least one callback must be provided.',
    );
    final _listeners = innerListeners;
    if (_listeners == null) return;
    for (final ObserverListenerEntry<M> entry in _listeners) {
      if (entry.context == context &&
          entry.onObserve == onObserve &&
          entry.onObserveAll == onObserveAll) {
        entry.unlink();
        return;
      }
    }
  }

  void _notifyListeners(
    Map<BuildContext, M> changeResultMap,
  ) {
    if (changeResultMap.isEmpty) return;
    final _listeners = innerListeners;
    if (_listeners == null || _listeners.isEmpty) return;

    final List<ObserverListenerEntry<M>> localListeners =
        List<ObserverListenerEntry<M>>.of(_listeners);
    for (final ObserverListenerEntry<M> entry in localListeners) {
      try {
        if (entry.list != null) {
          entry.onObserveAll?.call(changeResultMap);

          if (entry.onObserve != null) {
            // If sliverContext is not specified, the first one in
            // targetSliverContexts is taken.
            BuildContext? _sliverContext = entry.context;
            if (_sliverContext == null && targetSliverContexts.isNotEmpty) {
              _sliverContext = targetSliverContexts.first;
            }
            final result = changeResultMap[_sliverContext];
            if (result == null) continue;
            entry.onObserve?.call(result);
          }
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'scrollview_observer',
          context:
              ErrorDescription('while dispatching result for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<ObserverWidgetState>(
              'The $runtimeType sending result was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }
  }
}
