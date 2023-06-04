/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-27 22:49:41
 */

import 'dart:math';
import 'package:scrollview_observer_example/features/scene/chat_demo/model/chat_model.dart';

class ChatDataHelper {
  static List<String> chatContents = [
    'My name is LinXunFeng',
    'Twitter: https://twitter.com/xunfenghellolo'
        'Github: https://github.com/LinXunFeng',
    'Blog: https://fullstackaction.com/',
    'Juejin: https://juejin.cn/user/1820446984512392/posts',
    'Artile: Flutter-获取ListView当前正在显示的Widget信息\nhttps://juejin.cn/post/7103058155692621837',
    'Artile: Flutter-列表滚动定位超强辅助库，墙裂推荐！🔥\nhttps://juejin.cn/post/7129888644290068487',
    'A widget for observing data related to the child widgets being displayed in a scrollview.\nhttps://github.com/LinXunFeng/flutter_scrollview_observer',
    '📱 Swifty screen adaptation solution (Support Objective-C and Swift)\nhttps://github.com/LinXunFeng/SwiftyFitsize'
  ];

  static ChatModel createChatModel({
    bool? isOwn,
  }) {
    final random = Random();
    final content =
        ChatDataHelper.chatContents[random.nextInt(chatContents.length)];
    return ChatModel(
      isOwn: isOwn ?? random.nextBool(),
      content: content,
    );
  }
}
