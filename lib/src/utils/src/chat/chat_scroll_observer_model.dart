/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-13 10:33:00
 */
import 'chat_scroll_observer_typedefs.dart';

class ChatScrollObserverHandlePositionResultModel {
  /// The type of processing location.
  final ChatScrollObserverHandlePositionType type;

  /// The number of messages added.
  final int changeCount;

  ChatScrollObserverHandlePositionResultModel(
    this.type,
    this.changeCount,
  );
}
