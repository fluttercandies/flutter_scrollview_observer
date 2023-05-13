/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-13 12:29:56
 */

import 'dart:math';

class RandomTool {
  static int genInt({int min = 0, int max = 100}) {
    var x = Random().nextInt(max) + min;
    return x.floor();
  }
}
