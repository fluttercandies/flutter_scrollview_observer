# Flutter ScrollView Observer

[![author](https://img.shields.io/badge/author-LinXunFeng-blue.svg?style=flat-square&logo=Iconify)](https://github.com/LinXunFeng/) [![pub](https://img.shields.io/pub/v/scrollview_observer?&style=flat-square&label=pub&logo=dart)](https://pub.dev/packages/scrollview_observer) [![stars](https://img.shields.io/github/stars/LinXunFeng/flutter_scrollview_observer?style=flat-square&logo=github)](https://github.com/LinXunFeng/flutter_scrollview_observer)

Language: 中文 | [English](https://github.com/LinXunFeng/flutter_scrollview_observer) | [文章](https://juejin.cn/post/7103058155692621837/)

这是一个可用于监听滚动视图中正在显示的子部件的组件库。

## 支持
- [x] `ListView`
- [x] `SliverList`
- [x] `GridView`
- [x] `SliverGrid` 

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

`ListViewObserver` 的参数说明：

|参数|必传|说明|
|-|-|-|
|`child`|是|将构建的 `ListView` 做为 `ListViewObserver` 的子部件|
|`sliverListContexts`|否|该回调中返回需要被观察的 `ListView` 的 `BuildContext`，在需要精确指定 `BuildContext` 时才会用到该参数|
|`onObserve`|否|该回调可以监听到当前 `第一个` `Sliver` 中正在显示中的子部件的相关信息|
|`onObserveAll`|否|该回调可以监听到当前 `所有` `Sliver` 正在显示中的子部件的相关信息，当有多个 `Sliver` 时才需要使用到这个回调|

### 方式一：常规（推荐）

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

### 方式二：指明 `Sliver` 的 `BuildContext`

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

## 示例

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/3.gif)

## 关于我

- GitHub: [https://github.com/LinXunFeng](https://github.com/LinXunFeng)
- Email: [linxunfeng@yeah.net](mailto:linxunfeng@yeah.net)
- Blogs: 
  - 全栈行动: [https://fullstackaction.com](https://fullstackaction.com)
  - 掘金: [https://juejin.cn/user/1820446984512392](https://juejin.cn/user/1820446984512392) 

<img height="267.5" width="481.5" src="https://github.com/LinXunFeng/LinXunFeng/raw/master/static/img/FSAQR.png"/>
