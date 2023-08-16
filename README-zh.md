# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: 中文 | [English](https://github.com/LinXunFeng/flutter_scrollview_observer)

这是一个可用于监听滚动视图中正在显示的子部件的组件库。

## 请我喝一杯咖啡 ☕

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T4JKVRP) [![wechat](https://img.shields.io/static/v1?label=WeChat&message=微信收款码&color=brightgreen&style=for-the-badge&logo=WeChat)](https://cdn.jsdelivr.net/gh/FullStackAction/PicBed@resource20220417121922/image/202303181116760.jpeg)

微信技术交流群请看: [【微信群说明】](https://mp.weixin.qq.com/s/JBbMstn0qW6M71hh-BRKzw)

## 文章

- [Flutter - 获取ListView当前正在显示的Widget信息](https://mp.weixin.qq.com/s/cN3qeinBPlo5rtEpoQBVVA) | [备用链接](https://juejin.cn/post/7103058155692621837)
- [Flutter - 列表滚动定位超强辅助库，墙裂推荐！🔥](https://mp.weixin.qq.com/s/fplqfBpXwvx6mEO6vflkww) | [备用链接](https://juejin.cn/post/7129888644290068487)
- [Flutter - 快速实现聊天会话列表的效果，完美💯](https://mp.weixin.qq.com/s/xNiGuSLcJtDAiLoHuGWp6A) | [备用链接](https://juejin.cn/post/7152307272436154405)
- [Flutter - 船新升级😱支持观察第三方构建的滚动视图💪](https://mp.weixin.qq.com/s/FMXPyT-lX8YOXVmbLCsVUA) | [备用链接](https://juejin.cn/post/7240751116702269477)
- [Flutter - 瀑布流交替播放视频 🎞](https://mp.weixin.qq.com/s/miP5CfKtcRhFGr08ot5wOg) | [备用链接](https://juejin.cn/post/7243240589293142077)
- [Flutter - IM保持消息位置大升级(支持ChatGPT生成式消息) 🤖](https://mp.weixin.qq.com/s/Y3EN9ZpLb6HLke2vkw0Zwg) | [备用链接](https://juejin.cn/post/7245753944180523067)
- [Flutter - 滚动视图中的表单防遮挡 🗒](https://mp.weixin.qq.com/s/iaHyYMjZSPBggLw2yZv8dQ) | [备用链接](https://juejin.cn/spost/7266455050632921107)

## 功能点

> 不需要改变你当前所使用视图，只需要在视图外包裹一层即可实现如下功能点

- [x] 监听滚动视图中正在显示的子部件
- [x] 支持滚动到指定下标位置
- [x] 快速实现聊天会话列表的效果
- [x] 支持在插入或更新消息时保持IM消息位置，避免抖动

## 支持
- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 
- [x] 支持 `SliverPersistentHeader`，`SliverList` 和 `SliverGrid` 混合使用
- [x] 由第三方库构建的 `ScrollView`

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

| 参数                      | 必传 | 说明                                                                                                        |
| ------------------------- | ---- | ----------------------------------------------------------------------------------------------------------- |
| `child`                   | 是   | 将构建的 `ListView` 做为 `ListViewObserver` 的子部件                                                        |
| `sliverListContexts`      | 否   | 该回调中返回需要被观察的 `ListView` 的 `BuildContext`，在需要精确指定 `BuildContext` 时才会用到该参数       |
| `onObserve`               | 否   | 该回调可以监听到当前 `第一个` `Sliver` 中正在显示中的子部件的相关信息                                       |
| `onObserveAll`            | 否   | 该回调可以监听到当前 `所有` `Sliver` 正在显示中的子部件的相关信息，当有多个 `Sliver` 时才需要使用到这个回调 |
| `leadingOffset`           | 否   | 列表头部的计算偏移量，从该偏移量开始计算首个子部件                                                          |
| `dynamicLeadingOffset`    | 否   | `leadingOffset` 的动态版本，在列表头部的计算偏移量不确定时使用，优先级高于 `leadingOffset`                  |
| `toNextOverPercent`       | 否   | 首个子部件被遮挡的百分比达到该值时，则下一个子部件为首个子部件，默认值为 `1`                                |
| `autoTriggerObserveTypes` | 否   | 用于设置自动触发观察的时机                                                                                  |
| `triggerOnObserveType`    | 否   | 用于配置触发 [onObserve] 或 [onObserveAll] 回调的前提                                                       |

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

`dispatchOnceObserve` 方法的定义：

以 `ListObserverController` 的为例

```dart
Future<ListViewOnceObserveNotificationResult> dispatchOnceObserve({
  BuildContext? sliverContext,
  bool isForce = false,
  bool isDependObserveCallback = true,
})
```

`dispatchOnceObserve` 的参数说明：

| 参数                      | 必传 | 说明                                                                                                   |
| ------------------------- | ---- | ------------------------------------------------------------------------------------------------------ |
| `sliverContext`           | 否   | 滚动视图的 `BuildContext`，只有在 `CustomScrollView` 有多个 `Sliver` 时才会使用到                      |
| `isForce`                 | 否   | 是否强制观察，等同于 `ObserverTriggerOnObserveType.directly`                                           |
| `isDependObserveCallback` | 否   | 是否依赖于判断 `onObserve` 等回调有没有实现，如果传 `true`，即使没有实现对应的回调，也可以拿到观察结果 |

其返回值可以直接拿到观察的结果！

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

#### 1.1、`autoTriggerObserveTypes` 参数

用于设置自动触发观察的时机，定义如下：

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

其默认值为 `[.scrollStart, .scrollUpdate, .scrollEnd]`

枚举值说明：

| 枚举值         | 描述     |
| -------------- | -------- |
| `scrollStart`  | 开始滚动 |
| `scrollUpdate` | 滚动中   |
| `scrollEnd`    | 结束滚动 |

#### 1.2、`triggerOnObserveType` 参数

用于配置触发 `[onObserve]` 和 `[onObserveAll]` 回调的前提，定义如下：

```dart
final ObserverTriggerOnObserveType triggerOnObserveType;
```

```dart
enum ObserverTriggerOnObserveType {
  directly,
  displayingItemsChange,
}
```

其默认值为 `.displayingItemsChange`

枚举值说明：

| 枚举值                  | 描述                                               |
| ----------------------- | -------------------------------------------------- |
| `directly`              | 观察到数据后直接将数据返出                         |
| `displayingItemsChange` | 当列表子部件进出或数量发生变化时将观察到的数据返出 |

#### 1.3、`onObserveViewport` 回调

> 仅支持 `CustomScrollView`

用于观察当前 `CustomScrollView` 的 `Viewport` 中有哪些指定的 `Sliver` 正在展示

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
#### 1.4、`customTargetRenderSliverType` 回调

> 仅支持 `ListViewObserver` 和 `GridViewObserver`

在保持原来的观察逻辑上，告诉该库要处理的 `RenderSliver`，目的是为了支持对第三方库构建的列表进行观察。

```dart
customTargetRenderSliverType: (renderObj) {
  // 告诉该库它需要观察什么类型的RenderObject
  return renderObj is ExtendedRenderSliverList;
},
```

#### 1.5、`customHandleObserve` 回调

该回调用于自定义观察逻辑，当自带的处理逻辑不符合你的需求时使用。

```dart
customHandleObserve: (context) {
  // 完全自定义你的观察逻辑
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

#### 1.6、`extendedHandleObserve` 回调

> 仅支持 `SliverViewObserver`

该回调用于对原来的观察逻辑进行补充，原来只处理 `RenderSliverList`、`RenderSliverFixedExtentList` 和 `RenderSliverGrid`。

```dart
extendedHandleObserve: (context) {
  // 在对原来的观察逻辑进行拓展
  final _obj = ObserverUtils.findRenderObject(context);
  if (_obj is RenderSliverWaterfallFlow) {
    return ObserverCore.handleGridObserve(context: context);
  }
  return null;
},
```

### 2、滚动到指定下标位置

建议搭配滚动视图的 `cacheExtent` 属性使用，将其赋予适当的值可避免不必要的翻页，分为以下几种情况:

- 如果子部件是固定高度则使用 `isFixedHeight` 参数即可，不用设置 `cacheExtent`
- 如果是详细页这类滚动视图，建议将 `cacheExtent` 设置为 `double.maxFinite`
- 如果为子部件不等高的滚动视图，建议根据自身情况将 `cacheExtent` 设置为比较大且合理的值

#### 2.1、基本使用
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

#### 2.2、`padding` 参数

如果你的 `ListView` 或 `GridView` 有用到其 `padding` 参数时，也需要同步给该值！如:

```dart
ListView.separated(padding: _padding, ...);
GridView.builder(padding: _padding, ...);
```

```dart
observerController.jumpTo(index: 1, padding: _padding);
```

⚠ 请不要在 `CustomScrollView` 中使用 `SliverPadding`

#### 2.3、`isFixedHeight` 参数

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

#### 2.4、`offset` 参数

> 用于在滚动到指定下标位置时，设置整体的偏移量。

如在有 `SliverAppBar` 的场景下，其高度会随着 `ScrollView` 的滚动而变化，到达一定的偏移量后会固定高度悬浮于顶部，这时就需要使用到 `offset` 参数了。

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
    // 根据目标偏移量 offset，计算出 SliverAppBar 的高度并返回
    // observerController 内部会根据该返回值做适当的偏移调整
    return ObserverUtils.calcPersistentHeaderExtent(
      key: appBarKey,
      offset: offset,
    );
  },
);
```

#### 2.5、`alignment` 参数

`alignment` 参数用于指定你期望定位到子部件的对齐位置，该值需要在 `[0.0, 1.0]` 这个范围之间。默认为 `0`，比如：

- `alignment: 0` : 滚动到子部件的顶部位置
- `alignment: 0.5` : 滚动到子部件的中间位置
- `alignment: 1` : 滚动到子部件的尾部位置

#### 2.6、`cacheJumpIndexOffset` 属性

为了性能考虑，在默认情况下，列表在滚动到指定位置时，`ScrollController` 会对子部件的信息进行缓存，便于下次直接使用。

但是对于子部件高度一直都是动态改变的场景下，这反而会造成不必要的麻烦，所以这时可以通过对 `cacheJumpIndexOffset` 属性设置为 `false` 来关闭这一缓存功能。

#### 2.7、`clearIndexOffsetCache` 方法

如果你想保留滚动的缓存功能，并且只想在特定情况下去清除缓存，则可以使用 `clearIndexOffsetCache` 方法。

```dart
/// Clear the offset cache that jumping to a specified index location.
clearIndexOffsetCache(BuildContext? sliverContext) {
  ...
}
```

其形参 `sliverContext` 只有在你自行管理 `ScrollView` 的 `BuildContext` 时才需要传递。

#### 2.8、初始下标位置

- 方式一: `initialIndex`

最简单的使用方式，直接指定下标即可

```dart
observerController = ListObserverController(controller: scrollController)
  ..initialIndex = 10;
```

- 方式二: `initialIndexModel`

定制初始下标位置的配置，各参数说明请看该节的最后部分

```dart
observerController = ListObserverController(controller: scrollController)
  ..initialIndexModel = ObserverIndexPositionModel(
    index: 10,
    isFixedHeight = true,
    alignment = 0.5,
  );
```

- 方式三: `initialIndexModelBlock`

回调内返回 `ObserverIndexPositionModel` 对象, 适用于在一些参数无法一开始就可以确定的场景下使用，如 `sliverContext`

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

`ObserverIndexPositionModel` 的定义:

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
| 属性            | 类型                                   | 描述                                                                                        |
| --------------- | -------------------------------------- | ------------------------------------------------------------------------------------------- |
| `index`         | `int`                                  | 初始下标                                                                                    |
| `sliverContext` | `BuildContext`                         | 滚动视图的 `BuildContext`                                                                   |
| `isFixedHeight` | `bool`                                 | 如果列表子部件的高度是固定的，则建议使用 `isFixedHeight` 参数提升性能，默认为 `false`       |
| `alignment`     | `double`                               | 指定你期望定位到子部件的对齐位置，该值需要在 `[0.0, 1.0]` 这个范围之间。默认为 `0`          |
| `offset`        | `double Function(double targetOffset)` | 用于在滚动到指定下标位置时，设置整体的偏移量                                                |
| `padding`       | `EdgeInsets`                           | 当你的 `ListView` 或 `GridView` 有用到 `padding` 参数时，也需要同步给该值，其实情况则不需要 |

### 3、聊天会话

#### 3.1、基本使用
只需要三个步骤即可实现聊天会话页的列表效果

- 1、聊天数据不满一屏时，顶部显示所有聊天数据
- 2、插入消息时
  - 如果最新消息紧靠列表底部时，则插入消息会使列表向上推
  - 如果不是紧靠列表底部，则固定到当前聊天位置

步骤一：初始化必要的 `ListObserverController` 和 `ChatScrollObserver`
```dart
/// 初始化 ListObserverController
observerController = ListObserverController(controller: scrollController)
  ..cacheJumpIndexOffset = false;

/// 初始化 ChatScrollObserver
chatObserver = ChatScrollObserver(observerController)
  // 超过该偏移量才会触发保持当前聊天位置的功能
  ..fixedPositionOffset = 5
  ..toRebuildScrollViewCallback = () {
    // 这里可以重建指定的滚动视图即可
    setState(() {});
  };
```

步骤二：按如下配置 `ListView` 并使用 `ListViewObserver` 将其包裹

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

步骤三：插入或删除消息前，调用 `ChatScrollObserver` 的 `standby` 方法

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

默认只处理插入一条消息的情况，如果你需要一次性插入多条，那 `standby` 需要传入 `changeCount` 参数

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

注：该功能依赖被插入消息前的最新消息视图做为参照去计算偏移量，所以如果一次性插入的消息数太多，导致该参照消息视图无法得到渲染，则该功能会失效，需要你自己去对 `ScrollView` 的 `cacheExtent` 设置合理的值来尽量避免这个问题！

#### 3.2、聊天消息位置的处理回调

```dart
chatObserver = ChatScrollObserver(observerController)
  ..onHandlePositionResultCallback = (result) {
    switch (result.type) {
      case ChatScrollObserverHandlePositionType.keepPosition:
        // 保持当前聊天消息位置
        // updateUnreadMsgCount(changeCount: result.changeCount);
        break;
      case ChatScrollObserverHandlePositionType.none:
        // 对聊天消息位置不做处理
        // updateUnreadMsgCount(isReset: true);
        break;
    }
  };
```

该回调的主要作用：在新增聊天消息时，处理新消息未读数气泡的展示

#### 3.3、生成式消息保持位置

像 `ChatGPT` 那样不断变化的生成式消息，在翻看旧消息时也需要保持消息位置，你只需要在 `standby` 方法中调整一下处理模式即可

```dart
chatObserver.standby(
  mode: ChatScrollObserverHandleMode.generative,
  // changeCount: 1,
);
```

注: 内部会根据 `changeCount` 来决定参照的 `item`，且仅支持生成式消息为连续的情况。

#### 3.4、指定参照的消息

如果你的生成式消息是不连续的，或者同一时间内即有生成式消息更新，又有增加与删除消息的行为，在这种复杂的情况下，则需要你自己指定参照 `item`，且这个处理模式更具有灵活性。

```dart
chatObserver.standby(
  changeCount: 1,
  mode: ChatScrollObserverHandleMode.specified,
  refItemRelativeIndex: 2,
  refItemRelativeIndexAfterUpdate: 2,
);
```

1. 设置 `mode` 为 `.specified`
2. 设置更新 `前` 的参照 `item` 的相对下标
3. 设置更新 `后` 的参照 `item` 的相对下标


注: 相对下标指的是当前屏幕中正在显示的 `item` 所对应的相对下标，如下所示

```shell
     trailing        relativeIndex
-----------------  -----------------
|     item4     |          4
|     item3     |          3
|     item2     |          2
|     item1     |          1
|     item0     |          0 
-----------------  -----------------
     leading
```


```shell
     trailing        relativeIndex
-----------------  -----------------
|     item14    |          4
|     item13    |          3
|     item12    |          2
|     item11    |          1
|     item10    |          0 
-----------------  -----------------
     leading
```

请记住，你的 `refItemRelativeIndex` 和 `refItemRelativeIndexAfterUpdate` 不论你如何设置，它都应该是指向同一个消息对象！


### 4、模型属性

#### `ObserveModel`

> 监听模型的基类

| 属性                       | 类型           | 描述                       |
| -------------------------- | -------------- | -------------------------- |
| `sliver`                   | `RenderSliver` | 当前 `sliver`              |
| `visible`                  | `bool`         | `sliver` 是否可见          |
| `displayingChildIndexList` | `List<int>`    | 当前现在显示的子部件的下标 |
| `axis`                     | `Axis`         | `sliver` 的方向            |
| `scrollOffset`             | `double`       | `sliver` 的偏移量          |

#### `ListViewObserveModel`

> 继承自 `ObserveModel`，`ListView` 和 `SliverList` 专用的监听模型

| 属性                       | 类型                                        | 描述                               |
| -------------------------- | ------------------------------------------- | ---------------------------------- |
| `sliver`                   | `RenderSliverMultiBoxAdaptor`               | 当前 `sliver`                      |
| `firstChild`               | `ListViewObserveDisplayingChildModel`       | 当前第一个正在显示的子部件数据模型 |
| `displayingChildModelList` | `List<ListViewObserveDisplayingChildModel>` | 当前正在显示的所有子部件数据模型   |

#### `GridViewObserveModel`

> 继承自 `ObserveModel`，`GridView` 和 `SliverGrid` 专用的监听模型

| 属性                       | 类型                                        | 描述                                   |
| -------------------------- | ------------------------------------------- | -------------------------------------- |
| `sliverGrid`               | `RenderSliverGrid`                          | 当前 `sliver`                          |
| `firstGroupChildList`      | `List<GridViewObserveDisplayingChildModel>` | 当前第一排正在显示的所有子部件数据模型 |
| `displayingChildModelList` | `List<GridViewObserveDisplayingChildModel>` | 当前正在显示的所有子部件数据模型       |

#### `ObserveDisplayingChildModel`

> 当前正在显示的子部件的数据信息

| 属性           | 类型           | 描述                          |
| -------------- | -------------- | ----------------------------- |
| `sliver`       | `RenderSliver` | 当前 `sliver`                 |
| `index`        | `int`          | 子部件的下标                  |
| `renderObject` | `RenderBox`    | 子部件对应的 `RenderBox` 实例 |

#### `ObserveDisplayingChildModelMixin`

> 当前正在显示的子部件的数据信息，是对 `ObserveDisplayingChildModel` 的补充

| 属性                       | 类型     | 描述                           |
| -------------------------- | -------- | ------------------------------ |
| `axis`                     | `Axis`   | `sliver` 的方向                |
| `size`                     | `Size`   | 子部件的大小                   |
| `mainAxisSize`             | `double` | 子部件主轴方向上的大小         |
| `scrollOffset`             | `double` | `sliver` 的偏移量              |
| `layoutOffset`             | `double` | 子部件相应于 `sliver` 的偏移量 |
| `leadingMarginToViewport`  | `double` | 子部件距离视口顶部的距离       |
| `trailingMarginToViewport` | `double` | 子部件距离视口尾部部的距离     |
| `displayPercentage`        | `double` | 子部件自身大小显示的占比       |

## 示例

### 1、ListView / SliverList

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/4.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/9.gif)

### 2、GridView / SliverGrid

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/7.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/8.gif)

### 3、CustomScrollView

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/5.gif)

### 4、应用场景

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/6.gif)

## 关于我

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>
