/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-13 10:33:00
 */
import 'package:flutter/material.dart';

import 'package:scrollview_observer/src/common/models/observe_displaying_child_model_mixin.dart';
import 'package:scrollview_observer/src/utils/src/chat/chat_scroll_observer.dart';
import 'package:scrollview_observer/src/utils/src/chat/chat_scroll_observer_typedefs.dart';

class ChatScrollObserverHandlePositionResultModel {
  /// The type of processing location.
  final ChatScrollObserverHandlePositionType type;

  /// The mode of processing.
  final ChatScrollObserverHandleMode mode;

  /// The number of messages added.
  final int changeCount;

  ChatScrollObserverHandlePositionResultModel({
    required this.type,
    required this.mode,
    required this.changeCount,
  });
}

class ChatScrollObserverCustomAdjustPositionDeltaModel {
  /// The old position.
  final ScrollMetrics oldPosition;

  /// The new position.
  final ScrollMetrics newPosition;

  /// Whether the ScrollView is scrolling.
  final bool isScrolling;

  /// The current velocity of the scroll position.
  final double velocity;

  /// The [ChatScrollObserver] instance.
  final ChatScrollObserver observer;

  /// The observation result of the current item.
  final ObserveDisplayingChildModelMixin currentItemModel;

  ChatScrollObserverCustomAdjustPositionDeltaModel({
    required this.oldPosition,
    required this.newPosition,
    required this.isScrolling,
    required this.velocity,
    required this.observer,
    required this.currentItemModel,
  });
}
