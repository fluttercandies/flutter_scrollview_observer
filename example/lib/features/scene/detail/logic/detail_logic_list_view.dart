/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 21:02:30
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/common/route/route.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_nav_bar.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

extension DetailLogicForListView on DetailLogic {
  void onInitForListView() {
    state.scrollController.addListener(() {
      if (!state.scrollController.hasClients) return;
      updateNavBarAlpha();
    });
  }

  void onDisposeForListView() {
    state.scrollController.dispose();
  }

  void onObserveForListView(ListViewObserveModel result) {
    final navBarTabController = state.navBarTabController;
    if (navBarTabController == null) return;

    final index = ObserverUtils.calcAnchorTabIndex(
      observeModel: result,
      tabIndexes: state.navBarTabs.map((e) => e.index).toList(),
      currentTabIndex: navBarTabController.index,
    );
    updateNavBarTabIndex(index);
  }

  void initIndexPositionForListView() {
    final defaultIndexModel = ObserverIndexPositionModel(
      index: 0,
    );
    ObserverIndexPositionModel indexModel = defaultIndexModel;

    () {
      final moduleAnchor = state.defaultModuleAnchor;
      if (moduleAnchor == null) return;

      // Modules loaded asynchronously do not need to be processed.
      if (state.asyncLoadModuleTypes.contains(moduleAnchor)) return;
      indexModel = ObserverIndexPositionModel(
        index: state.moduleTypes.indexOf(moduleAnchor),
        offset: (_) => state.navBarHeight,
      );
    }();

    state.observerController.initialIndexModel = indexModel;
  }

  /// Specifically designed to handle those module anchors that are loaded
  /// asynchronously.
  void checkAnchorForListView(DetailModuleType moduleType) async {
    final moduleAnchor = state.defaultModuleAnchor;
    if (moduleAnchor == null) return;
    if (moduleType != moduleAnchor) return;
    if (!state.moduleTypes.contains(moduleType)) return;
    final index = state.moduleTypes.indexOf(moduleType);
    await WidgetsBinding.instance.endOfFrame;
    state.observerController.animateTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: (_) => state.navBarHeight,
    );
  }

  /// When updating the module widget, keep the current position unchanged.
  void updateAndKeepPositionForListView([
    List<Object>? ids,
  ]) {
    () async {
      final result = await state.observerController.dispatchOnceObserve(
        isForce: true,
        isDependObserveCallback: false,
      );
      final observeResult = result.observeResult;
      if (observeResult == null) return;
      final firstChild = observeResult.firstChild;
      if (firstChild == null) return;
      final refItemIndex = firstChild.index;
      // Keep position
      state.keepPositionObserver.standby(
        mode: ChatScrollObserverHandleMode.specified,
        refItemIndex: refItemIndex,
        refItemIndexAfterUpdate: refItemIndex,
      );
    }();

    update(ids);
  }

  /// Show loading first, and hide loading after setting the index of the
  /// TabBar and scrolling to the corresponding module.
  void firstTimeRenderListView() async {
    await Future.delayed(const Duration(milliseconds: 100));
    state.showLoading = false;
    update([DetailUpdateType.loading]);
  }

  void loadAsyncDataForListView() {
    // Load Module3 and Module6 asynchronously
    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (state.isDisposed) return;
      state.haveDataForModule3 = true;
      // update([DetailUpdateType.module3]);
      updateAndKeepPositionForListView([DetailUpdateType.module3]);
      checkAnchorForListView(DetailModuleType.module3);
      SnackBarUtil.showSnackBar(
        context: NavigationService.context,
        text: 'Module3 has been displayed',
      );
    });

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (state.isDisposed) return;
      state.haveDataForModule6 = true;
      // update([DetailUpdateType.module6]);
      updateAndKeepPositionForListView([DetailUpdateType.module6]);
      checkAnchorForListView(DetailModuleType.module6);
      SnackBarUtil.showSnackBar(
        context: NavigationService.context,
        text: 'Module6 has been displayed',
      );
    });
  }
}
