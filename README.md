# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: English | [中文](https://github.com/LinXunFeng/flutter_scrollview_observer/blob/main/README-zh.md)


This is a library of widget that can be used to listen for child widgets those are being displayed in the scroll view.

## Support me ☕

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T4JKVRP) [![wechat](https://img.shields.io/static/v1?label=WeChat&message=WeChat&nbsp;Pay&color=brightgreen&style=for-the-badge&logo=WeChat)](https://cdn.jsdelivr.net/gh/FullStackAction/PicBed@resource20220417121922/image/202303181116760.jpeg)

Chat: [Join WeChat group](https://mp.weixin.qq.com/s/JBbMstn0qW6M71hh-BRKzw)

## Article


- [Flutter - 获取ListView当前正在显示的Widget信息](https://mp.weixin.qq.com/s?__biz=Mzg4MTA4MDQzMQ==&mid=2247484946&idx=1&sn=3ac31edb56bff934df49b862b13b0012&chksm=cf6a2712f81dae04727edddadf2d6ac725ef29af854a9e23e4d7bed568d02bde45bf8adff8e4&token=1260106697&lang=zh_CN#rd) | [备用链接](https://juejin.cn/post/7103058155692621837)
- [Flutter - 列表滚动定位超强辅助库，墙裂推荐！🔥](https://mp.weixin.qq.com/s?__biz=Mzg4MTA4MDQzMQ==&mid=2247485055&idx=1&sn=eab481355ed53e11d5ac4ec9f5fc3172&chksm=cf6a277ff81dae6946afd8fb89ea43d2b05cbf5b3b5ad108e951be4d7b1cf808fd81b0b591b8&token=1260106697&lang=zh_CN#rd) | [备用链接](https://juejin.cn/post/7129888644290068487)
- [Flutter - 快速实现聊天会话列表的效果，完美💯](https://mp.weixin.qq.com/s?__biz=Mzg4MTA4MDQzMQ==&mid=2247485070&idx=1&sn=8dd84b714da27233f98f4acaa422ff5b&chksm=cf6a278ef81dae9829c4af95163ae9a553d3729627260b84b0a7d5391fc5c3945091d09a389b&token=1260106697&lang=zh_CN#rd) | [备用链接](https://juejin.cn/post/7152307272436154405)
- [Flutter - 船新升级😱支持观察第三方构建的滚动视图💪](https://mp.weixin.qq.com/s?__biz=Mzg4MTA4MDQzMQ==&mid=2247485290&idx=1&sn=4e41637c0f740544dca59dbd1e9a9d8a&chksm=cf6a266af81daf7c2cf76b335c4de271991936d7d6d18d816d64113b29808aa686dcf5a192b5&token=1260106697&lang=zh_CN#rd) | [备用链接](https://juejin.cn/post/7240751116702269477)

## Feature

> You do not need to change the view you are currently using, just wrap a `ViewObserver` around the view to achieve the following features.

- [x] Observing child widgets those are being displayed in the scroll view
- [x] Supports scrolling to the specified index location
- [x] Quickly implement the chat session page effect

## Support

- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 
- [x] Mixing usage of `SliverPersistentHeader`, `SliverList` and `SliverGrid`
- [x] `ScrollView` built by third-party package.

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

| `Parameter`               | `Required` | `Description`                                                                                                                                                                           |
| ------------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `child`                   | `yes`      | Create `[ListView]` as a child of `[ListViewObserver]`                                                                                                                                  |
| `sliverListContexts`      | `no`       | In this callback, we need to return all `[BuildContext]` of the `[ListView]` those needs to be observed. This property is only used when `[BuildContext]` needs to be specified exactly |
| `onObserve`               | `no`       | This callback can listen for information about the child widgets those are currently being displayed in the current first `[Sliver]`                                                    |
| `onObserveAll`            | `no`       | This callback can listen for information about all the children of slivers that are currently being displayed. This callback is only needed when there are more than one `[Sliver]`     |
| `leadingOffset`           | `no`       | The offset of the head of scroll view. Find the first child start at this offset.                                                                                                       |
| `dynamicLeadingOffset`    | `no`       | This is a callback that provides `[leadingOffset]`, used when the leading offset in the head of the scroll view is dynamic. It has a higher priority than `[leadingOffset]`             |
| `toNextOverPercent`       | `no`       | When the percentage of the first child widget is blocked reaches this value, the next child widget will be the first child that is displaying. The default value is `1`                 |
| `autoTriggerObserveTypes` | `no`       | Used to set types those can trigger observe automatically                                                                                                                               |
| `triggerOnObserveType`    | `no`       | Used to set the prerequisite for triggering [onObserve] callback and [onObserveAll] callback                                                                                            |

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

#### 1.1、Parameter `autoTriggerObserveTypes`

Used to set types those can trigger observe automatically, defined as follows:

```dart
final List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes;
```

```dart
enum ObserverAutoTriggerObserveType {
  scrollStart,
  scrollUpdate,
  scrollEnd,
}
```

Defaults to `[.scrollStart, .scrollUpdate, .scrollEnd]`.

Description of enum values as follow：

| value          | Desc                                                          |
| -------------- | ------------------------------------------------------------- |
| `scrollStart`  | when a `[Scrollable]` widget has started scrolling.           |
| `scrollUpdate` | when a `[Scrollable]` widget has changed its scroll position. |
| `scrollEnd`    | when a `[Scrollable]` widget has stopped scrolling.           |

#### 1.2、Parameter `triggerOnObserveType`

Used to set the prerequisite for triggering [onObserve] callback and [onObserveAll] callback, defined as follows:

```dart
final ObserverTriggerOnObserveType triggerOnObserveType;
```

```dart
enum ObserverTriggerOnObserveType {
  directly,
  displayingItemsChange,
}
```

Defaults to `.displayingItemsChange`.

Description of enum values as follow：

| value                   | Desc                                                                                                                   |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `directly`              | The callback `onObserve` will be called directly when getting observed result for scrollView.                          |
| `displayingItemsChange` | The callback `onObserve` will be called when child widget comes in and out or when the number of child widget changes. |

#### 1.3、Callback `onObserveViewport`

> Only `CustomScrollView` is supported.

Used to observe which specified `slivers` are being displayed in the `Viewport` of `CustomScrollView`.

```dart
SliverViewObserver(
  child: _buildScrollView(),
  sliverContexts: () {
    return [
      if (grid1Context != null) grid1Context!,
      if (swipeContext != null) swipeContext!,
      if (grid2Context != null) grid2Context!,
    ];
  },
  onObserveViewport: (result) {
    firstChildCtxInViewport = result.firstChild.sliverContext;
    if (firstChildCtxInViewport == grid1Context) {
      debugPrint('current first sliver in viewport - gridView1');
    } else if (firstChildCtxInViewport == swipeContext) {
      debugPrint('current first sliver in viewport - swipeView');
    } else if (firstChildCtxInViewport == grid2Context) {
      debugPrint('current first sliver in viewport - gridView2');
    }
  },
)
```
#### 1.4、Callback `customTargetRenderSliverType`

> Only `ListViewObserver` and `GridViewObserver` are supported.

While maintaining the original observation logic, tell the package the `RenderSliver` to be observed, in order to support the observation of the list built by the third-party package.

```dart
customTargetRenderSliverType: (renderObj) {
  // Here you tell the package what type of RenderObject it needs to observe.
  return renderObj is ExtendedRenderSliverList;
},
```

#### 1.5、Callback `customHandleObserve`

This callback is used to customize the observation logic and is used when the built-in observation logic does not meet your needs.

```dart
customHandleObserve: (context) {
  // Here you can customize the observation logic.
  final _obj = ObserverUtils.findRenderObject(context);
  if (_obj is RenderSliverList) {
    ObserverCore.handleListObserve(context: context);
  }
  if (_obj is RenderSliverGrid || _obj is RenderSliverWaterfallFlow) {
    return ObserverCore.handleGridObserve(context: context);
  }
  return null;
},
```

#### 1.6、Callback `extendedHandleObserve`

> Only `SliverViewObserver` is supported.

This callback is used to supplement the original observation logic, which originally only dealt with `RenderSliverList`, `RenderSliverFixedExtentList` and `RenderSliverGrid`.

```dart
extendedHandleObserve: (context) {
  // An extension of the original observation logic.
  final _obj = ObserverUtils.findRenderObject(context);
  if (_obj is RenderSliverWaterfallFlow) {
    return ObserverCore.handleGridObserve(context: context);
  }
  return null;
},
```

### 2、Scrolling to the specified index location

It should be used with the scrollView's `cacheExtent` property. Assigning an appropriate value to it can avoid unnecessary page turning. 
The recommendations are as follows:

- If child widgets are fixed height in scrollView, use `isFixedHeight` instead of `cacheExtent`.
- For scrollView such as detail page, it is recommended to set `cacheExtent` to `double.maxFinite`.
- If child widgets are dynamic height in scrollView, it is recommended that setting `cacheExtent` to a large and reasonable value depending on your situation.

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

#### 2.2、Parameter `padding`

If your ListView or GridView uses its padding parameter, you need to sync that value as well! Such as:

```dart
ListView.separated(padding: _padding, ...);
GridView.builder(padding: _padding, ...);
```

```dart
observerController.jumpTo(index: 1, padding: _padding);
```

⚠ Do not use `SliverPadding` in `CustomScrollView`.

#### 2.3、Parameter `isFixedHeight` 

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


#### 2.4、Parameter `offset`

> Used to set the whole scrollView offset when scrolling to a specified index.

For example, in the scene with `SliverAppBar`, its height will change with the scrolling of `ScrollView`. After reaching a certain offset, it will be suspended on the top with a fixed height, and then we must pass this fixed height to the `offset` parameter.

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

#### 2.5、Parameter `alignment`

The `alignment` specifies the desired position for the leading edge of the child widget. It must be a value in the range `[0.0, 1.0]`. Such as:

- `alignment: 0` : Scrolling to the `top` position of the child widget.
- `alignment: 0.5` : Scrolling to the `middle` position of the child widget.
- `alignment: 1` : Scrolling to the `tail` position of the child widget.

#### 2.6、Property `cacheJumpIndexOffset`

For performance reasons, `ScrollController` will caches the child's information by default when the listView `jump` or `animate` to the specified location, so that it can be used next time directly.

However, in scence where the height of child widget is always changing dynamically, this will cause unnecessary trouble, so you can turn this off by setting the `cacheJumpIndexOffset` property to `false`.

#### 2.7、Method `clearIndexOffsetCache`

You can use the `clearIndexOffsetCache` method if you want to preserve the cache function of scrolling and only want to clear the cache in certain cases.

```dart
/// Clear the offset cache that jumping to a specified index location.
clearIndexOffsetCache(BuildContext? sliverContext) {
  ...
}
```

The parameter `sliverContext` needs to be passed only if you manage `ScrollView`'s `BuildContext` by yourself.

#### 2.8、Initial index location

- Method 1: `initialIndex`

The simplest way to use, directly set the location index.

```dart
observerController = ListObserverController(controller: scrollController)
  ..initialIndex = 10;
```

- Method 2: `initialIndexModel`

You can customize the configuration of the initial index position.
See the end of this section for property descriptions.

```dart
observerController = ListObserverController(controller: scrollController)
  ..initialIndexModel = ObserverIndexPositionModel(
    index: 10,
    isFixedHeight = true,
    alignment = 0.5,
  );
```

- Method 3: `initialIndexModelBlock`

You need return ` ObserverIndexPositionModel ` object within the callback.

This method applies to some of scenarios those the parameters can't be determined from the start, such as `sliverContext`.

```dart
observerController = SliverObserverController(controller: scrollController)
  ..initialIndexModelBlock = () {
    return ObserverIndexPositionModel(
      index: 6,
      sliverContext: _sliverListCtx,
      offset: calcPersistentHeaderExtent,
    );
  };
```

The structure of `ObserverIndexPositionModel` :

```dart
ObserverIndexPositionModel({
  required this.index,
  this.sliverContext,
  this.isFixedHeight = false,
  this.alignment = 0,
  this.offset,
  this.padding = EdgeInsets.zero,
});
```

| Property        | Type                                   | Desc                                                                                                                                                   |
| --------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `index`         | `int`                                  | The index of child widget.                                                                                                                             |
| `sliverContext` | `BuildContext`                         | The target sliver `[BuildContext]`.                                                                                                                    |
| `isFixedHeight` | `bool`                                 | If the height of the child widget and the height of the separator are fixed, please pass `true` to this property. Defaults to `false`                  |
| `alignment`     | `double`                               | The alignment specifies the desired position for the leading edge of the child widget. It must be a value in the range `[0.0, 1.0]`. Defaults to `1.0` |
| `offset`        | `double Function(double targetOffset)` | Use this property when locating position needs an offset.                                                                                              |
| `padding`       | `EdgeInsets`                           | If your ListView or GridView uses its padding parameter, you need to sync that value as well! Otherwise it is not required.                            |

### 3、Chat Observer
#### 3.1、Basic usage

We only need three steps to implement the chat session page effect.

- 1、All chat data are displayed at the top of the listView when there is less than one screen of chat data.
- 2、When inserting a chat data
  - If the latest message is close to the bottom of the list, the listView will be pushed up.
  - Otherwise, the listView will be fixed to the current chat location.

Step 1: Initialize the necessary `ListObserverController` and `ChatScrollObserver`.

```dart
/// Initialize ListObserverController
observerController = ListObserverController(controller: scrollController)
  ..cacheJumpIndexOffset = false;

/// Initialize ChatScrollObserver
chatObserver = ChatScrollObserver(observerController)
  // Greater than this offset will be fixed to the current chat location.
  ..fixedPositionOffset = 5
  ..toRebuildScrollViewCallback = () {
    // Here you can use other way to rebuild the specified listView instead of [setState]
    setState(() {});
  };
```

Step 2: Configure `ListView` as follows and wrap it with `ListViewObserver`.

```dart
Widget _buildListView() {
  Widget resultWidget = ListView.builder(
    physics: ChatObserverClampinScrollPhysics(observer: chatObserver),
    shrinkWrap: chatObserver.isShrinkWrap,
    reverse: true,
    controller: scrollController,
    ...
  );

  resultWidget = ListViewObserver(
    controller: observerController,
    child: resultWidget,
  );
  return resultWidget;
}
```

Step 3: Call the [standby] method of `ChatScrollObserver` before inserting or removing chat data.

```dart
onPressed: () {
  chatObserver.standby();
  setState(() {
    chatModels.insert(0, ChatDataHelper.createChatModel());
  });
},
...
onRemove: () {
  chatObserver.standby(isRemove: true);
  setState(() {
    chatModels.removeAt(index);
  });
},
```

![](https://cdn.jsdelivr.net/gh/FullStackAction/PicBed@resource20220417121922/image/202209292333410.gif)

This feature only handles inserting one message by default. If you need to insert multiple messages at once, you can pass the `changeCount` parameter to the `standby` method.

```dart
_addMessage(int count) {
  chatObserver.standby(changeCount: count);
  setState(() {
    needIncrementUnreadMsgCount = true;
    for (var i = 0; i < count; i++) {
      chatModels.insert(0, ChatDataHelper.createChatModel());
    }
  });
}
```

Note: This feature relies on the latest message view before the message is inserted as a reference to calculate the offset, so if too many messages are inserted at once and the reference message view cannot be rendered, this feature will fail, and you need to try to avoid this problem by setting a reasonable value for `cacheExtent` of `ScrollView` by yourself!

#### 3.2、The result callback for processing chat location.

```dart
chatObserver = ChatScrollObserver(observerController)
  ..onHandlePositionResultCallback = (result) {
    switch (result.type) {
      case ChatScrollObserverHandlePositionType.keepPosition:
        // Keep the current chat location.
        // updateUnreadMsgCount(changeCount: result.changeCount);
        break;
      case ChatScrollObserverHandlePositionType.none:
        // Do nothing about the chat location.
        // updateUnreadMsgCount(isReset: true);
        break;
    }
  };
```

This callback is mainly used to display the unread bubbles of new messages when adding chat messages.

### 4、Model Property

#### `ObserveModel`

> The base class of the observing data.

| Property                   | Type           | Desc                                                         |
| -------------------------- | -------------- | ------------------------------------------------------------ |
| `sliver`                   | `RenderSliver` | The target sliver.                                           |
| `visible`                  | `bool`         | Whether this sliver should be painted.                       |
| `displayingChildIndexList` | `List<int>`    | Stores index list for children widgets those are displaying. |
| `axis`                     | `Axis`         | The axis of sliver.                                          |
| `scrollOffset`             | `double`       | The scroll offset of sliver.                                 |

#### `ListViewObserveModel`

> A special observing models which inherits from the `ObserveModel` for `ListView` and `SliverList`.

| Property                   | Type                                        | Desc                                                             |
| -------------------------- | ------------------------------------------- | ---------------------------------------------------------------- |
| `sliver`                   | `RenderSliverMultiBoxAdaptor`               | The target sliverList.                                           |
| `firstChild`               | `ListViewObserveDisplayingChildModel`       | The observing data of the first child widget that is displaying. |
| `displayingChildModelList` | `List<ListViewObserveDisplayingChildModel>` | Stores observing model list of displaying children widgets.      |

#### `GridViewObserveModel`

> A special observing models which inherits from the `ObserveModel` for `GridView` and `SliverGrid`.

| Property                   | Type                                        | Desc                                                         |
| -------------------------- | ------------------------------------------- | ------------------------------------------------------------ |
| `sliverGrid`               | `RenderSliverGrid`                          | The target sliverGrid.                                       |
| `firstGroupChildList`      | `List<GridViewObserveDisplayingChildModel>` | The observing datas of first group displaying child widgets. |
| `displayingChildModelList` | `List<GridViewObserveDisplayingChildModel>` | Stores observing model list of displaying children widgets.  |

#### `ObserveDisplayingChildModel`

> Data information about the child widget that is currently being displayed.

| Property       | Type           | Desc                                            |
| -------------- | -------------- | ----------------------------------------------- |
| `sliver`       | `RenderSliver` | The target sliverList.                          |
| `index`        | `int`          | The index of child widget.                      |
| `renderObject` | `RenderBox`    | The renderObject `[RenderBox]` of child widget. |

#### `ObserveDisplayingChildModelMixin`

> The currently displayed child widgets data information, is for `ObserveDisplayingChildModel` supplement.

| Property                   | Type     | Desc                                                            |
| -------------------------- | -------- | --------------------------------------------------------------- |
| `axis`                     | `Axis`   | The axis of sliver.                                             |
| `size`                     | `Size`   | The size of child widget.                                       |
| `mainAxisSize`             | `double` | The size of child widget on the main axis.                      |
| `scrollOffset`             | `double` | The scroll offset of sliver.                                    |
| `layoutOffset`             | `double` | The layout offset of child widget.                              |
| `leadingMarginToViewport`  | `double` | The margin from the top of the child widget to the viewport.    |
| `trailingMarginToViewport` | `double` | The margin from the bottom of the child widget to the viewport. |
| `displayPercentage`        | `double` | The display percentage of the current widget.                   |


## Example

### 1、ListView / SliverList

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/4.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/9.gif)

### 2、GridView / SliverGrid

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/7.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/8.gif)

### 3、CustomScrollView

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/5.gif)

### 4、Scene

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/6.gif)

## About Me

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>