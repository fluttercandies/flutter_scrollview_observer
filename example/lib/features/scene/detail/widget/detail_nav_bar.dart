/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 16:59:04
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_nav_bar.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';

class DetailNavBar extends StatefulWidget {
  const DetailNavBar({super.key});

  @override
  State<DetailNavBar> createState() => _DetailNavBarState();
}

class _DetailNavBarState extends State<DetailNavBar>
    with DetailLogicConsumerMixin<DetailNavBar> {
  DetailState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailLogic>(
      tag: logicTag,
      id: DetailUpdateType.navBar,
      builder: (_) {
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    Widget resultWidget = Container(
      height: state.navBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: state.navBarAlpha > 0
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.transparent,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: _buildTabBar(),
    );
    resultWidget = Opacity(
      opacity: state.navBarAlpha,
      child: resultWidget,
    );
    resultWidget = IgnorePointer(
      ignoring: state.navBarAlpha < 0.2,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildTabBar() {
    final navBarTabController = state.navBarTabController;
    if (navBarTabController == null) return const SizedBox();
    return TabBar(
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: state.navBarTabs.map((e) => Tab(text: e.title)).toList(),
      controller: navBarTabController,
      indicatorColor: Colors.blueAccent,
      indicatorWeight: 3.0,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey[600],
      labelStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 14.0),
      labelPadding: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      dividerColor: Colors.transparent,
      onTap: logic.handleNavBarTabTap,
    );
  }
}
