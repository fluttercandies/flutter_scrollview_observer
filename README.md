# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: English | [中文](https://github.com/LinXunFeng/flutter_scrollview_observer/blob/main/README-zh.md) | [Article](https://juejin.cn/post/7103058155692621837/)


This is a library of widget that can be used to listen for child widgets those are being displayed in the scroll view.
## Feature

- [x] Observing child widgets those are being displayed in the scroll view
- [x] Supports scrolling to the specified index location

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

### 1、Observing child widgets those are being displayed in the scroll view

Parameter description of `ListViewObserver`:

| `Parameter`            | `Required` | `Description`                                                                                                                                                                           |
| ---------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `child`                | `yes`      | Create `[ListView]` as a child of `[ListViewObserver]`                                                                                                                                  |
| `sliverListContexts`   | `no`       | In this callback, we need to return all `[BuildContext]` of the `[ListView]` those needs to be observed. This property is only used when `[BuildContext]` needs to be specified exactly |
| `onObserve`            | `no`       | This callback can listen for information about the child widgets those are currently being displayed in the current first `[Sliver]`                                                    |
| `onObserveAll`         | `no`       | This callback can listen for information about all the children of slivers that are currently being displayed. This callback is only needed when there are more than one `[Sliver]`     |
| `leadingOffset`        | `no`       | The offset of the head of scroll view. Find the first child start at this offset.                                                                                                      |
| `dynamicLeadingOffset` | `no`       | This is a callback that provides `[leadingOffset]`, used when the leading offset in the head of the scroll view is dynamic. It has a higher priority than `[leadingOffset]`                                                                                             |
| `toNextOverPercent`    | `no`       | When the percentage of the first child widget is blocked reaches this value, the next child widget will be the first child that is displaying. The default value is `1`                                                                                                            |

#### Method 1: General (Recommended)

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

#### Method 2: Specify `BuildContext` for `Sliver`

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


### 2、Scrolling to the specified index location

Create and use instance of `ScrollController` normally.

```dart
ScrollController scrollController = ScrollController();

ListView _buildListView() {
  return ListView.separated(
    controller: scrollController,
    ...
  );
}
```

Create an instance of `ListObserverController` pass it to `ListViewObserver`

```dart
ListObserverController observerController = ListObserverController(controller: scrollController);

ListViewObserver(
  controller: observerController,
  child: _buildListView(),
  ...
)
```

Now you can scroll to the specified index position

```dart
// Jump to the specified index position without animation.
observerController.jumpTo(index: 1)

// Jump to the specified index position with animation.
observerController.animateTo(
  index: 1,
  duration: const Duration(milliseconds: 250),
  curve: Curves.ease,
);
```

## Example

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)

## About Me

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>