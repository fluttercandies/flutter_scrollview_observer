/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 21:02:30
 */

import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_nav_bar.dart';

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

    navBarTabController.index = ObserverUtils.calcAnchorTabIndex(
      observeModel: result,
      tabIndexs: state.navBarTabs.map((e) => e.index).toList(),
      currentTabIndex: navBarTabController.index,
    );
  }
}
