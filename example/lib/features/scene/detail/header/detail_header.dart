/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 19:57:05
 */

import 'package:flutter/material.dart';
import 'package:getx_helper/getx_helper.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';

typedef DetailLogicPutMixin<W extends StatefulWidget>
    = GetxLogicPutStateMixin<DetailLogic, W>;

typedef DetailLogicConsumerMixin<W extends StatefulWidget>
    = GetxLogicConsumerStateMixin<DetailLogic, W>;

enum DetailUpdateType {
  navBar,
  config,
  loading,
  module3,
  module6,
}

enum DetailModuleType {
  module1,
  module2,
  module3,
  module4,
  module5,
  module6,
  module7,
  module8,
}

enum DetailRefreshIndicatorType {
  none,
  footer,
}
