# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: 中文 | [English](https://github.com/LinXunFeng/flutter_scrollview_observer) | [文章](https://juejin.cn/post/7103058155692621837/)

这是一个可用于监听滚动视图中正在显示的子部件的组件库。
## 功能点

> 不需要改变你当前所使用视图，只需要在视图外包裹一层即可实现如下功能点

- [x] 监听滚动视图中正在显示的子部件
- [x] 支持滚动到指定下标位置

## 支持
- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 
- [x] 支持 `SliverList` 和 `SliverGrid` 混合使用

## 安装

在你的 `pubspec.yaml` 文件中添加 `scrollview_observer` 依赖:

```yaml
dependencies:
  scrollview_observer: latest_version
```

在需要使用的地方导入 `scrollview_observer` :

```dart
import 'package:scrollview_observer/scrollview_observer.dart';
```

## 使用

> 以 `ListView` 为例

### 1、监听滚动视图中正在显示的子部件

`ListViewObserver` 的参数说明：

| 参数                   | 必传 | 说明                                                                                                        |
| ---------------------- | ---- | ----------------------------------------------------------------------------------------------------------- |
| `child`                | 是   | 将构建的 `ListView` 做为 `ListViewObserver` 的子部件                                                        |
| `sliverListContexts`   | 否   | 该回调中返回需要被观察的 `ListView` 的 `BuildContext`，在需要精确指定 `BuildContext` 时才会用到该参数       |
| `onObserve`            | 否   | 该回调可以监听到当前 `第一个` `Sliver` 中正在显示中的子部件的相关信息                                       |
| `onObserveAll`         | 否   | 该回调可以监听到当前 `所有` `Sliver` 正在显示中的子部件的相关信息，当有多个 `Sliver` 时才需要使用到这个回调 |
| `leadingOffset`        | 否   | 列表头部的计算偏移量，从该偏移量开始计算首个子部件                                                          |
| `dynamicLeadingOffset` | 否   | `leadingOffset` 的动态版本，在列表头部的计算偏移量不确定时使用，优先级高于 `leadingOffset`                  |
| `toNextOverPercent`    | 否   | 首个子部件被遮挡的百分比达到该值时，则下一个子部件为首个子部件，默认值为 `1`                                |

#### 方式一：常规（推荐）

> 使用上比较简单，应用范围广，一般情况下只需要使用该方式

构建 `ListViewObserver`，将 `ListView` 实例传递给 `child` 参数

```dart
ListViewObserver(
  child: _buildListView(),
  onObserve: (resultModel) {
    print('firstChild.index -- ${resultModel.firstChild?.index}');
    print('displaying -- ${resultModel.displayingChildIndexList}');
  },
)
```

默认是 `ListView` 在滚动的时候才会观察到相关数据。

如果需要，可以使用 `ListObserverController` 进行手动触发一次观察

```dart
// 创建 `ListObserverController` 实例
ListObserverController controller = ListObserverController();
...

// 传递给 `ListViewObserver` 的 `controller` 参数
ListViewObserver(
  ...
  controller: controller,
  ...
)
...

// 手动触发一次观察
controller.dispatchOnceObserve();
```

#### 方式二：指明 `Sliver` 的 `BuildContext`

> 使用上相对复杂，应用范围小，存在多个 `Sliver` 时才有可能会用到该方式

<details>
  <summary>具体说明</summary>

```dart
BuildContext? _sliverListViewContext;
```

创建 `ListView`，并在其 `builder` 回调中，将 `BuildContext` 记录起来

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

构建 `ListViewObserver`

```dart
ListViewObserver(
  child: _buildListView(),
  sliverListContexts: () {
    return [if (_sliverListViewContext != null) _sliverListViewContext!];
  },
  onObserve: (resultMap) {
    final model = resultMap[_sliverListViewContext];
    if (model == null) return;

    // 打印当前正在显示的第一个子部件
    print('firstChild.index -- ${model.firstChild?.index}');

    // 打印当前正在显示的所有子部件下标
    print('displaying -- ${model.displayingChildIndexList}');
  },
)
```

默认是 `ListView` 在滚动的时候才会观察到相关数据。

如果需要，可以使用 `ListViewOnceObserveNotification` 进行手动触发一次观察

```dart
ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
```
  
</details>

### 2、滚动到指定下标位置

正常创建和使用 `ScrollController` 实例

```dart
ScrollController scrollController = ScrollController();

ListView _buildListView() {
  return ListView.separated(
    controller: scrollController,
    ...
  );
}
```

创建 `ListObserverController` 实例并将其传递给 `ListViewObserver`

```dart
ListObserverController observerController = ListObserverController(controller: scrollController);

ListViewObserver(
  controller: observerController,
  child: _buildListView(),
  ...
)
```

现在即可滚动到指定下标位置了

```dart
// 无动画滚动至下标位置
observerController.jumpTo(index: 1)

// 动画滚动至下标位置
observerController.animateTo(
  index: 1,
  duration: const Duration(milliseconds: 250),
  curve: Curves.ease,
);
```

如果列表子部件的高度是固定的，则建议使用 `isFixedHeight` 参数提升性能

⚠ 目前仅支持 `ListView` 或 `SliverList`

```dart
// 无动画滚动至下标位置
observerController.jumpTo(index: 150, isFixedHeight: true)

// 动画滚动至下标位置
observerController.animateTo(
  index: 150, 
  isFixedHeight: true
  duration: const Duration(milliseconds: 250),
  curve: Curves.ease,
);
```

如果你的视图是 `CustomScrollView`，其 `slivers` 中包含了 `SliverList` 和 `SliverGrid`，这种情况也是支持的，只不过需要使用 `SliverViewObserver`，并在调用滚动方法时传入对应的 `BuildContext` 以区分对应的 `Sliver`。

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

### 3、模型属性

#### `ObserveModel`

> 监听模型的基类

|属性|类型|描述|
|-|-|-|
|`sliver`|`RenderSliver`|当前 `sliver`|
|`visible`|`bool`|`sliver` 是否可见|
|`displayingChildIndexList`|`List<int>`|当前现在显示的子部件的下标|
|`axis`|`Axis`|`sliver` 的方向|
|`scrollOffset`|`double`|`sliver` 的偏移量|

#### `ListViewObserveModel`

> 继承自 `ObserveModel`，`ListView` 和 `SliverList` 专用的监听模型

|属性|类型|描述|
|-|-|-|
|`sliver`|`RenderSliver`|当前 `sliver`|
|`firstChild`|`ListViewObserveDisplayingChildModel`|当前第一个正在显示的子部件数据模型|
|`displayingChildModelList`|`List<ListViewObserveDisplayingChildModel>`|当前正在显示的所有子部件数据模型|

#### `GridViewObserveModel`

> 继承自 `ObserveModel`，`GridView` 和 `SliverGrid` 专用的监听模型

|属性|类型|描述|
|-|-|-|
|`sliverGrid`|`RenderSliverGrid`|当前 `sliver`|
|`firstGroupChildList`|`List<GridViewObserveDisplayingChildModel>`|当前第一排正在显示的所有子部件数据模型|
|`displayingChildModelList`|`List<GridViewObserveDisplayingChildModel>`|当前正在显示的所有子部件数据模型|

#### `ObserveDisplayingChildModel`

> 当前正在显示的子部件的数据信息

|属性|类型|描述|
|-|-|-|
|`sliver`|`RenderSliver`|当前 `sliver`|
|`index`|`int`|子部件的下标|
|`renderObject`|`RenderBox`|子部件对应的 `RenderBox` 实例|

#### `ObserveDisplayingChildModelMixin`

> 当前正在显示的子部件的数据信息，是对 `ObserveDisplayingChildModel` 的补充

|属性|类型|描述|
|-|-|-|
|`axis`|`Axis`|`sliver` 的方向|
|`size`|`Size`|子部件的大小|
|`mainAxisSize`|`double`|子部件主轴方向上的大小|
|`scrollOffset`|`double`|`sliver` 的偏移量|
|`layoutOffset`|`double`|子部件相应于 `sliver` 的偏移量|
|`leadingMarginToViewport`|`double`|子部件距离视口顶部的距离|
|`trailingMarginToViewport`|`double`|子部件距离视口尾部部的距离|
|`displayPercentage`|`double`|子部件自身大小显示的占比|

## 示例

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/4.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/5.gif)

## 关于我

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>
