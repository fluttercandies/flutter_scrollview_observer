# Flutter ScrollView Observer

This is a widget designed for `ListView` and `SliverListView` to listen for which parts are being displayed.

## Installing

Add `scrollview_observer` to your pubspec.yaml file:


```yaml
dependencies:
  scrollview_observer: ^0.0.1
```

Import `scrollview_observer` in files that it will be used:

```dart
import 'package:scrollview_observer/scrollview_observer.dart';
```

## Getting Started

```dart
BuildContext? _sliverListViewContext;
```

Create a `ListView` and record `BuildContext` in its builder callback

```dart
ListView _buildListView() {
  return ListView.separated(
    itemBuilder: (ctx, index) {
      if (_sliverListViewContext != ctx) {
        _sliverListViewContext = ctx;
      }
      return _buildListItemView(index);
    },
    separatorBuilder: (ctx, index) {
      return _buildSeparatorView();
    },
    itemCount: 50,
  );
}
```

Create `ListViewObserver`

- `child`: Create `ListView` as a child of `ListViewObserver`
- `sliverListContexts`: In this callback, we need to return all `BuildContext` of the ListView those needs to be observed
- `onObserve`: This callback can listen for information about the child widgets those are currently being displayed

```dart
ListViewObserver(
  child: _buildListView(),
  sliverListContexts: () {
    return [if (_sliverListViewContext != null) _sliverListViewContext!];
  },
  onObserve: (resultMap) {
    final model = resultMap[_sliverListViewContext];
    if (model == null) return;

    // Prints the first child widget that is currently being displayed
    print('firstChild.index -- ${model.firstChild.index}');

    // Prints the index of all child widgets those are currently being displayed
    print('displaying -- ${model.displayingChildIndexList}');
  },
)
```

By default, `ListView` relevant data will only be observed when rolling.

If needed, you can use `ListViewOnceObserveNotification` triggered an observation manually.

```dart
ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
```

## Example

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)