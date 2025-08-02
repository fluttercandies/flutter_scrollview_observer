/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 15:49:58
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext get context => navigatorKey.currentState!.context;

  static void push(
    String location, {
    Object? extra,
  }) {
    context.push(
      location,
      extra: extra,
    );
  }

  static void pop() => context.pop();

  static dynamic getParam(
    String key, {
    dynamic defaultValue,
  }) {
    final state = routerState();
    final pathParam = state.pathParameters[key];
    if (pathParam != null) return pathParam;
    final extra = stateExtra();
    if (extra == null) {
      return defaultValue;
    }
    if (extra is Map) {
      return extra[key] ?? defaultValue;
    }
    return defaultValue;
  }

  static GoRouterState routerState() {
    return GoRouter.of(context).state;
  }

  static Object? stateExtra() {
    return routerState().extra;
  }
}
