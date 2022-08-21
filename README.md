# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: English | [中文](https://github.com/LinXunFeng/flutter_scrollview_observer/blob/main/README-zh.md)


This is a library of widget that can be used to listen for child widgets those are being displayed in the scroll view.


## Article

- [Flutter - 列表滚动定位超强辅助库，墙裂推荐！🔥](https://juejin.cn/post/7129888644290068487)
- [Flutter - 获取ListView当前正在显示的Widget信息](https://juejin.cn/post/7103058155692621837)

## Feature

> You do not need to change the view you are currently using, just wrap a `ViewObserver` around the view to achieve the following features.

- [x] Observing child widgets those are being displayed in the scroll view
- [x] Supports scrolling to the specified index location

## Support

- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 
- [x] Mixing usage of `SliverPersistentHeader`, `SliverList` and `SliverGrid`

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

#### 2.1、Basic usage

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

#### 2.2、Property `isFixedHeight` 

If the height of a list child widget is fixed, it is recommended to use the 'isFixedHeight' parameter to improve performance.

⚠ Currently only `ListView` or `SliverList` is supported.

```dart
// Jump to the specified index position without animation.
observerController.jumpTo(index: 150, isFixedHeight: true)

// Jump to the specified index position with animation.
observerController.animateTo(
  index: 150, 
  isFixedHeight: true
  duration: const Duration(milliseconds: 250),
  curve: Curves.ease,
);
```

If you use `CustomScrollView` and its `slivers` contain `SliverList` and `SliverGrid`, this is also supported, but you need to use `SliverViewObserver`, and pass the corresponding `BuildContext` to distinguish the corresponding `Sliver` when calling the scroll method.

```dart
SliverViewObserver(
  controller: observerController,
  child: CustomScrollView(
    controller: scrollController,
    slivers: [
      _buildSliverListView1(),
      _buildSliverListView2(),
    ],
  ),
  sliverListContexts: () {
    return [
      if (_sliverViewCtx1 != null) _sliverViewCtx1!,
      if (_sliverViewCtx2 != null) _sliverViewCtx2!,
    ];
  },
  ...
)
```

```dart
observerController.animateTo(
  sliverContext: _sliverViewCtx2, // _sliverViewCtx1
  index: 10,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);
```


#### 2.3、Property `offset`

> Used to set the whole scrollView offset when scrolling to a specified index.

For example, in the scene with `SliverAppBar`, its height will change with the scrolling of `ScrollView`. After reaching a certain offset, it will be suspended on the top with a fixed height, and then we must pass this fixed height to the offset property.

```dart
SliverAppBar(
  key: appBarKey,
  pinned: true,
  expandedHeight: 200,
  flexibleSpace: FlexibleSpaceBar(
    title: const Text('AppBar'),
    background: Container(color: Colors.orange),
  ),
);
```

```dart
observerController.animateTo(
  ...
  offset: (offset) {
    // The height of the SliverAppBar is calculated base on target offset and is returned in the current callback.
    // The observerController internally adjusts the appropriate offset based on the return value.
    return ObserverUtils.calcPersistentHeaderExtent(
      key: appBarKey,
      offset: offset,
    );
  },
);
```

### 3、Model Property

#### `ObserveModel`

> The base class of the observing data.

|Property|Type|Desc|
|-|-|-|
|`sliver`|`RenderSliver`|The target sliver.|
|`visible`|`bool`|Whether this sliver should be painted.|
|`displayingChildIndexList`|`List<int>`|Stores index list for children widgets those are displaying.|
|`axis`|`Axis`|The axis of sliver.|
|`scrollOffset`|`double`|The scroll offset of sliver.|

#### `ListViewObserveModel`

> A special observing models which inherits from the `ObserveModel` for `ListView` and `SliverList`.

|Property|Type|Desc|
|-|-|-|
|`sliver`|`RenderSliver`|The target sliverList.|
|`firstChild`|`ListViewObserveDisplayingChildModel`|The observing data of the first child widget that is displaying.|
|`displayingChildModelList`|`List<ListViewObserveDisplayingChildModel>`|Stores observing model list of displaying children widgets.|

#### `GridViewObserveModel`

> A special observing models which inherits from the `ObserveModel` for `GridView` and `SliverGrid`.

|Property|Type|Desc|
|-|-|-|
|`sliverGrid`|`RenderSliverGrid`|The target sliverGrid.|
|`firstGroupChildList`|`List<GridViewObserveDisplayingChildModel>`|The observing datas of first group displaying child widgets.|
|`displayingChildModelList`|`List<GridViewObserveDisplayingChildModel>`|Stores observing model list of displaying children widgets.|

#### `ObserveDisplayingChildModel`

> Data information about the child widget that is currently being displayed.

|Property|Type|Desc|
|-|-|-|
|`sliver`|`RenderSliver`|The target sliverList.|
|`index`|`int`|The index of child widget.|
|`renderObject`|`RenderBox`|The renderObject `[RenderBox]` of child widget.|

#### `ObserveDisplayingChildModelMixin`

> The currently displayed child widgets data information, is for `ObserveDisplayingChildModel` supplement.

|Property|Type|Desc|
|-|-|-|
|`axis`|`Axis`|The axis of sliver.|
|`size`|`Size`|The size of child widget.|
|`mainAxisSize`|`double`|The size of child widget on the main axis.|
|`scrollOffset`|`double`|The scroll offset of sliver.|
|`layoutOffset`|`double`|The layout offset of child widget.|
|`leadingMarginToViewport`|`double`|The margin from the top of the child widget to the viewport.|
|`trailingMarginToViewport`|`double`|The margin from the bottom of the child widget to the viewport.|
|`displayPercentage`|`double`|The display percentage of the current widget.|


## Example

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/4.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/5.gif)

## About Me

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>