/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-05 22:38:33
 */

import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_list_view.dart';

extension DetailLogicForConfig on DetailLogic {
  void onConfigConfirm() {
    state.defaultModuleAnchor = state.configSelectedAnchor;
    state.showConfig = false;

    initIndexPositionForListView();

    // The synchronization data required for the ListView is loaded.
    update();

    // Now it's the first time the ListView is rendered.
    firstTimeRenderListView();

    // Load asynchronous data.
    loadAsyncDataForListView();
  }
}
