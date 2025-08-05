/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 19:57:05
 */

import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_list_view.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_nav_bar.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';

class DetailLogic extends GetxController with GetTickerProviderStateMixin {
  final DetailState state = DetailState();

  @override
  void onInit() {
    super.onInit();

    onInitForNavBar();
    onInitForListView();
  }

  void onDispose() {
    onDisposeForNavBar();
    onDisposeForListView();
  }
}
