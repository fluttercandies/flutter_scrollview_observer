/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-28 10:19:23
 */

import 'package:flutter/material.dart';

class AzListContactModel {
  final String section;
  final List<String> names;

  AzListContactModel({
    required this.section,
    required this.names,
  });
}

class AzListCursorInfoModel {
  final String title;
  final Offset offset;

  AzListCursorInfoModel({
    required this.title,
    required this.offset,
  });
}
