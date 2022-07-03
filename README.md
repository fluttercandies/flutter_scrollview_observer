# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: English | [中文](https://github.com/LinXunFeng/flutter_scrollview_observer/blob/main/README-zh.md) | [Article](https://juejin.cn/post/7103058155692621837/)


This is a library of widget that can be used to listen for child widgets those are being displayed in the scroll view.

## Support
- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 

## Installing

Add `scrollview_observer` to your pubspec.yaml file:


```yaml
dependencies:
  scrollview_observer: latest_version
```

Import `scrollview_observer` in files that it will be used:

```dart
import 'package:scrollview_observer/scrollview_observer.dart';
```

## Getting Started

> Take `ListView` as an example

Parameter description of `ListViewObserver`:

|`Parameter`|`Required`|`Description`|
|-|-|-|
|`child`|`yes`|Create `[ListView]` as a child of `[ListViewObserver]`|
|`sliverListContexts`|`no`|In this callback, we need to return all `[BuildContext]` of the `[ListView]` those needs to be observed. This property is only used when `BuildContext` needs to be specified exactly|
|`onObserve`|`no`|This callback can listen for information about the child widgets those are currently being displayed in the current first `[Sliver]`|
|`onObserveAll`|`no`|This callback can listen for information about all the children of slivers that are currently being displayed. This callback is only needed when there are more than one `[Sliver]`|


### Method 1: General (Recommended)

> It is relatively simple to use and has a wide application range. In general, only this method is needed

Build `ListViewObserver` and pass the `ListView` instance to the `child` parameter

```dart
ListViewObserver(
  child: _buildListView(),
  onObserve: (resultModel) {
    print('firstChild.index -- ${resultModel.firstChild?.index}');
    print('displaying -- ${resultModel.displayingChildIndexList}');
  },
)
```

By default, `ListView` relevant data will only be observed when scrolling.

If needed, you can use `ListObserverController` triggered an observation manually.

```dart
// Create an instance of [ListObserverController]
ListObserverController controller = ListObserverController();
...

// Pass the controller instance to the 'controller' parameter of 'ListViewObserver'
ListViewObserver(
  ...
  controller: controller,
  ...
)
...

// Trigger an observation manually.
controller.dispatchOnceObserve();
```

### Method 2: specify `BuildContext` for `Sliver`

> Relatively complex to use, the scope of application is small, there are more than one `Sliver` is possible to use this method

<details>
  <summary>Detailed instructions</summary>

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
      ...
    },
    ...
  );
}
```

Create `ListViewObserver`

```dart
ListViewObserver(
  child: _buildListView(),
  sliverListContexts: () {
    return [if (_sliverListViewContext != null) _sliverListViewContext!];
  },
  onObserve: (resultMap) {
    final model = resultMap[_sliverListViewContext];
    if (model == null) return;

    // Prints the first child widget index that is currently being displayed
    print('firstChild.index -- ${model.firstChild?.index}');

    // Prints the index of all child widgets those are currently being displayed
    print('displaying -- ${model.displayingChildIndexList}');
  },
)
```

By default, `ListView` relevant data will only be observed when scrolling.

If needed, you can use `ListViewOnceObserveNotification` triggered an observation manually.

```dart
ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
```
  
</details>

## Example

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)