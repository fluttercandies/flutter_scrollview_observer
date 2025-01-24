/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-10-31 14:57:45
 */

import 'package:scrollview_observer/src/utils/src/chat/chat_scroll_observer_model.dart';

/// Customize the delta of the adjustPosition.
typedef ChatScrollObserverCustomAdjustPositionDelta = double? Function(
  ChatScrollObserverCustomAdjustPositionDeltaModel,
);

/// Customize the scroll position should be given new viewport dimensions.
typedef ChatScrollObserverCustomAdjustPosition = double? Function(
  ChatScrollObserverCustomAdjustPositionModel,
);

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

enum ChatScrollObserverRefIndexType {
  ///     relativeIndex        trailing
  ///
  ///           6         |     item16    | cacheExtent
  ///   ----------------- -----------------
  ///           5         |     item15    |
  ///           4         |     item14    |
  ///           3         |     item13    | displaying
  ///           2         |     item12    |
  ///           1         |     item11    |
  ///   ----------------- -----------------
  ///           0         |     item10    | cacheExtent <---- start
  ///
  ///                          leading
  relativeIndexStartFromCacheExtent,

  ///     relativeIndex        trailing
  ///
  ///           5         |     item16    | cacheExtent
  ///   ----------------- -----------------
  ///           4         |     item15    |
  ///           3         |     item14    |
  ///           2         |     item13    | displaying
  ///           1         |     item12    |
  ///           0         |     item11    |             <---- start
  ///   ----------------- -----------------
  ///          -1         |     item10    | cacheExtent
  ///
  ///                          leading
  relativeIndexStartFromDisplaying,

  /// Directly specify the index of item.
  itemIndex,
}
