/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-21 12:50:50
 */

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? ambiguate<T>(T? value) => value;

/// Signature for the callback when scrolling to the specified index location
/// with offset.
/// For example, return the height of the sticky widget.
///
/// The [targetOffset] property is the offset of the planned locate.
typedef ObserverLocateIndexOffsetCallback = double Function(
    double targetOffset);

/// Observation result types in ObserverWidget.
enum ObserverWidgetObserveResultType {
  success,
  interrupted,
}
