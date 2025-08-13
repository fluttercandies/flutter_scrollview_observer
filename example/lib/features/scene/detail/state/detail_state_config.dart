/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-05 22:42:42
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';

mixin DetailStateForConfig {
  bool showConfig = true;

  DetailModuleType configSelectedAnchor = DetailModuleType.module7;

  List<DropdownMenuEntry<DetailModuleType>> get configDefaultAnchorEntries {
    List<DropdownMenuEntry<DetailModuleType>> entries = [];
    for (final moduleType in DetailModuleType.values) {
      entries.add(
        DropdownMenuEntry(
          value: moduleType,
          label: moduleType.name,
        ),
      );
    }
    return entries;
  }

  DetailRefreshIndicatorType configRefreshIndicator =
      DetailRefreshIndicatorType.none;

  List<DropdownMenuEntry<DetailRefreshIndicatorType>>
      get configRefreshIndicatorEntries {
    List<DropdownMenuEntry<DetailRefreshIndicatorType>> entries = [];
    for (final moduleType in DetailRefreshIndicatorType.values) {
      entries.add(
        DropdownMenuEntry(
          value: moduleType,
          label: moduleType.name,
        ),
      );
    }
    return entries;
  }
}
