# Flutter ScrollView Observer

这是针对 `ListView` 和 `SliverListView` 而设计的一个组件，可用于监听正在显示的是那些部件。

## 安装

在你的 `pubspec.yaml` 文件中添加 `scrollview_observer` 依赖:

```yaml
dependencies:
  scrollview_observer: ^0.0.1
```

在需要使用的地方导入 `scrollview_observer` :

```dart
import 'package:scrollview_observer/scrollview_observer.dart';
```

## 使用

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
      return _buildListItemView(index);
    },
    separatorBuilder: (ctx, index) {
      return _buildSeparatorView();
    },
    itemCount: 50,
  );
}
```

构建 `ListViewObserver`

- `child`: 将构建的 `ListView` 做为 `ListViewObserver` 的子部件
- `sliverListContexts`: 该回调中返回需要被观察的 `ListView` 的 `BuildContext`
- `onObserve`: 该回调可以监听到当前正在显示中的子部件的相关信息

```dart
ListViewObserver(
  child: _buildListView(),
  sliverListContexts: () {
    return [if (_sliverListViewContext != null) _sliverListViewContext!];
  },
  onObserve: (resultMap) {
    final model = resultMap[_sliverListViewContext];
    if (model == null) return;

    // 打印当前正在显示中的第一个子部件
    print('firstChild.index -- ${model.firstChild.index}');

    // 打印当前正在显示中的第一个子部件
    print('displaying -- ${model.displayingChildIndexList}');
  },
)
```

默认是 `ListView` 在滚动的时候才会观察到相关数据，如果需要，可以使用 `ListViewOnceObserveNotification` 进行手动触发一次观察

```dart
ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
```

## 示例

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/1.gif)

![](https://github.com/LinXunFeng/flutter_assets/raw/main/flutter_scrollview_observer/2.gif)