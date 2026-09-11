/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-27 23:12:45
 */

import 'package:material_ui/material_ui.dart';

import 'chat_observer_scroll_physics_mixin.dart';
import 'chat_scroll_observer.dart';

/// Deprecated scroll physics for chat observer clamping scroll physics.
/// Use [ChatObserverClampingScrollPhysics] instead.
@Deprecated(
  'It will be removed in version 2, please use [ChatObserverClampingScrollPhysics] instead',
)
class ChatObserverClampinScrollPhysics
    extends ChatObserverClampingScrollPhysics {
  /// Creates a [ChatObserverClampinScrollPhysics].
  ChatObserverClampinScrollPhysics({required super.observer});
}

class ChatObserverClampingScrollPhysics extends ClampingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverClampingScrollPhysics({
    super.parent,
    required ChatScrollObserver observer,
  }) {
    this.observer = observer;
  }

  @override
  ChatObserverClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatObserverClampingScrollPhysics(
      parent: buildParent(ancestor),
      observer: observer,
    );
  }
}

/// Bouncing scroll physics designed for chat scroll observer.
class ChatObserverBouncingScrollPhysics extends BouncingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  /// Creates a [ChatObserverBouncingScrollPhysics].
  ChatObserverBouncingScrollPhysics({
    super.parent,
    required ChatScrollObserver observer,
  }) {
    this.observer = observer;
  }

  @override
  ChatObserverBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatObserverBouncingScrollPhysics(
      parent: buildParent(ancestor),
      observer: observer,
    );
  }
}
