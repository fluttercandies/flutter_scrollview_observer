/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-04 22:18:57
 */

import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';

class DetailNavBarTabModel {
  final DetailModuleType type;

  final int index;

  String get title => '${type.name[0].toUpperCase()}${type.name.substring(1)}';

  DetailNavBarTabModel({
    required this.type,
    required this.index,
  });
}
