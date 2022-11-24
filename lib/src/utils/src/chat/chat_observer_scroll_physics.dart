/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-27 23:12:45
 */

import 'package:flutter/material.dart';
import 'chat_observer_scroll_physics_mixin.dart';
import 'chat_scroll_observer.dart';

@Deprecated(
    'It will be removed in version 2, please use [ChatObserverClampingScrollPhysics] instead')
class ChatObserverClampinScrollPhysics
    extends ChatObserverClampingScrollPhysics {
  ChatObserverClampinScrollPhysics({
    required ChatScrollObserver observer,
  }) : super(observer: observer);
}

class ChatObserverClampingScrollPhysics extends ClampingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverClampingScrollPhysics({
    ScrollPhysics? parent,
    required ChatScrollObserver observer,
  }) : super(parent: parent) {
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

class ChatObserverBouncingScrollPhysics extends BouncingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverBouncingScrollPhysics({
    ScrollPhysics? parent,
    required ChatScrollObserver observer,
  }) : super(parent: parent) {
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
