/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 20:03:56
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_list_view.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module1.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module2.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module3.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module4.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module5.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module6.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module7.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/list_item/detail_list_module8.dart';

class DetailListView extends StatefulWidget {
  const DetailListView({super.key});

  @override
  State<DetailListView> createState() => _DetailListViewState();
}

class _DetailListViewState extends State<DetailListView>
    with DetailLogicConsumerMixin<DetailListView> {
  DetailState get state => logic.state;

  List<DetailModuleType> get moduleTypes => state.moduleTypes;

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = ListView.separated(
      controller: state.scrollController,
      physics: ChatObserverClampingScrollPhysics(
        observer: state.keepPositionObserver,
      ),
      itemBuilder: (context, index) {
        switch (moduleTypes[index]) {
          case DetailModuleType.module1:
            return const DetailListModule1();
          case DetailModuleType.module2:
            return const DetailListModule2();
          case DetailModuleType.module3:
            return const DetailListModule3();
          case DetailModuleType.module4:
            return const DetailListModule4();
          case DetailModuleType.module5:
            return const DetailListModule5();
          case DetailModuleType.module6:
            return const DetailListModule6();
          case DetailModuleType.module7:
            return const DetailListModule7();
          case DetailModuleType.module8:
            return const DetailListModule8();
        }
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: moduleTypes.length,
      // Set a large enough cacheExtent to ensure that the keep position
      // function can work properly.
      //
      // More information and tips:
      // https://github.com/fluttercandies/flutter_scrollview_observer/wiki/3%E3%80%81Chat-Observer
      //
      // Since the content of the current page is small, maxFinite is set up.
      cacheExtent: double.maxFinite,
    );

    resultWidget = ListViewObserver(
      controller: state.observerController,
      dynamicLeadingOffset: () => state.navBarHeight,
      onObserve: logic.onObserveForListView,
      scrollNotificationPredicate: defaultScrollNotificationPredicate,
      child: resultWidget,
    );
    return resultWidget;
  }
}
