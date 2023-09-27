/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-13 12:29:56
 */

import 'dart:math';
import 'dart:ui';

class RandomTool {
  static int genInt({int min = 0, int max = 100}) {
    var x = Random().nextInt(max) + min;
    return x.floor();
  }

  static Color color() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      1,
    );
  }
}
