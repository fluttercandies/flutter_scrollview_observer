/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:16:49
 */

import 'package:material_ui/material_ui.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';

extension NestedScrollViewTabBarViewDemoLogicForObserver
    on NestedScrollViewTabBarViewDemoLogic {
  void updateNestedScrollUtilHeaderSliverContextsIfNeed({
    required BuildContext? oldCtx,
    required BuildContext newCtx,
    required Function() toRecordCtx,
  }) {
    if (oldCtx == newCtx) return;
    state.nestedScrollUtil.headerSliverContexts.remove(oldCtx);
    toRecordCtx.call();
    state.nestedScrollUtil.headerSliverContexts.add(newCtx);
  }

  void updateNestedScrollUtilBodySliverContextsIfNeed({
    required BuildContext? oldCtx,
    required BuildContext newCtx,
    required Function() toRecordCtx,
  }) {
    if (oldCtx == newCtx) return;
    state.nestedScrollUtil.bodySliverContexts.remove(oldCtx);
    toRecordCtx.call();
    state.nestedScrollUtil.bodySliverContexts.add(newCtx);
  }

  void handleOnObserveAll(Map<BuildContext, ObserveModel> resultMap) {
    resultMap.forEach((key, value) {
      // Header sliver list
      if (key == state.headerSliverListCtx) {
        final model = value as ListViewObserveModel;
        debugPrint("SliverListHeaderCtx: ${model.displayingChildIndexList}");
        if (state.hitIndexForHeaderListCtx == model.firstChild?.index) return;
        state.hitIndexForHeaderListCtx = model.firstChild?.index ?? 0;
        update([NestedScrollviewTabBarViewDemoUpdateType.headerSliverList]);
        return;
      }

      // Tab1 sliver list
      if (key == state.sliverTab1ListCtx) {
        final model = value as ListViewObserveModel;
        debugPrint("sliverTab1ListCtx: ${model.displayingChildIndexList}");
        if (state.hitIndexForTab1ListCtx == model.firstChild?.index) return;
        state.hitIndexForTab1ListCtx = model.firstChild?.index ?? 0;
        update([NestedScrollviewTabBarViewDemoUpdateType.tab1View]);
        return;
      }

      // Tab2 sliver grid
      if (key == state.tab2SliverGridCtx) {
        final model = value as GridViewObserveModel;
        debugPrint("sliverTab2GridCtx: ${model.displayingChildIndexList}");
        final firstGroupChildIndexList = model.firstGroupChildList
            .map((e) => e.index)
            .toList();
        if (state.hitIndexesForTab2Grid == firstGroupChildIndexList) return;
        state.hitIndexesForTab2Grid = firstGroupChildIndexList;
        update([NestedScrollviewTabBarViewDemoUpdateType.tab2View]);
        return;
      }

      // Tab3 sliver list
      if (key == state.tab3SliverListCtx) {
        final model = value as ListViewObserveModel;
        debugPrint("sliverTab3ListCtx: ${model.displayingChildIndexList}");
        if (state.hitIndexForTab3ListCtx == model.firstChild?.index) return;
        state.hitIndexForTab3ListCtx = model.firstChild?.index ?? 0;
        update([NestedScrollviewTabBarViewDemoUpdateType.tab3ViewSliverList]);
        return;
      }

      // Tab3 sliver grid
      if (key == state.tab3SliverGridCtx) {
        final model = value as GridViewObserveModel;
        debugPrint("sliverTab3GridCtx: ${model.displayingChildIndexList}");
        final firstGroupChildIndexList = model.firstGroupChildList
            .map((e) => e.index)
            .toList();
        if (state.hitIndexesForTab3Grid == firstGroupChildIndexList) return;
        state.hitIndexesForTab3Grid = firstGroupChildIndexList;
        update([NestedScrollviewTabBarViewDemoUpdateType.tab3ViewSliverGrid]);
        return;
      }
    });
  }

  void scrollTo({
    required NestedScrollUtilPosition position,
    required int index,
    required BuildContext? sliverContext,
  }) {
    bool isBody = NestedScrollUtilPosition.body == position;
    if (state.scrollToWithAnimation) {
      state.nestedScrollUtil.animateTo(
        nestedScrollViewKey: state.nestedScrollViewKey,
        observerController: state.observerController,
        position: position,
        index: index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        sliverContext: sliverContext,
        offset: (targetOffset) {
          return calcPersistentHeaderExtent(targetOffset, isBody: isBody);
        },
      );
    } else {
      state.nestedScrollUtil.jumpTo(
        nestedScrollViewKey: state.nestedScrollViewKey,
        observerController: state.observerController,
        position: position,
        index: index,
        sliverContext: sliverContext,
        offset: (targetOffset) {
          return calcPersistentHeaderExtent(targetOffset, isBody: isBody);
        },
      );
    }
  }

  double calcPersistentHeaderExtent(double offset, {required bool isBody}) {
    double value = ObserverUtils.calcPersistentHeaderExtent(
      key: state.appBarKey,
      offset: offset,
    );
    if (isBody) {
      value += ObserverUtils.calcPersistentHeaderExtent(
        key: state.tabBarKey,
        offset: offset,
      );
    }
    return value;
  }
}
