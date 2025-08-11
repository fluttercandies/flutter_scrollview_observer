/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 21:06:31
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/model/detail_nav_bar_tab_model.dart';

extension DetailLogicForNavBar on DetailLogic {
  void onInitForNavBar() {
    state.navBarTabs = [
      createNavBarTabModel(DetailModuleType.module1),
      createNavBarTabModel(DetailModuleType.module4),
      createNavBarTabModel(DetailModuleType.module7),
    ];
    state.navBarTabController = TabController(
      length: state.navBarTabs.length,
      vsync: this,
    );
  }

  DetailNavBarTabModel createNavBarTabModel(
    DetailModuleType type,
  ) {
    return DetailNavBarTabModel(
      type: type,
      index: state.moduleTypes.indexOf(type),
    );
  }

  void onDisposeForNavBar() {
    state.navBarTabController?.dispose();
    state.navBarTabController = null;
  }

  void handleNavBarTabTap(int index) {
    if (!state.scrollController.hasClients) return;

    final tabModel = state.navBarTabs[index];
    final moduleIndex = tabModel.index;
    if (moduleIndex == 0) {
      state.scrollController.jumpTo(0);
      return;
    }
    state.observerController.jumpTo(
      index: moduleIndex,
      offset: (_) => state.navBarHeight,
    );
  }

  void updateNavBarTabIndex(int index) {
    final navBarTabController = state.navBarTabController;
    if (navBarTabController == null) return;
    navBarTabController.index = index;
  }

  void updateNavBarAlpha() {
    if (!state.scrollController.position.hasPixels) return;
    state.scrollController.position.pixels;

    state.navBarHeight;
    state.navBarAlpha;

    final scrollOffset = state.scrollController.position.pixels;
    final navBarHeight = state.navBarHeight;

    double newAlpha = 0.0;
    newAlpha = min(
      1.0,
      max(0.0, scrollOffset / navBarHeight),
    );

    if (state.navBarAlpha == newAlpha) return;
    state.navBarAlpha = newAlpha;
    update([
      DetailUpdateType.navBar,
    ]);
  }
}
