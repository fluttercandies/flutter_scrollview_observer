/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-10-31 14:57:45
 */

enum ChatScrollObserverHandlePositionType {
  /// Nothing will be done.
  none,

  /// Keep the current chat location.
  keepPosition,
}

enum ChatScrollObserverHandleMode {
  /// Regular mode
  /// Such as inserting or deleting messages.
  normal,

  /// Generative mode
  /// Such as ChatGPT streaming messages.
  generative,

  /// Specified mode
  /// You can specify the index of the reference message in this mode.
  specified,
}
