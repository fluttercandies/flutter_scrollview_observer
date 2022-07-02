import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class AnchorListPage extends StatefulWidget {
  const AnchorListPage({Key? key}) : super(key: key);

  @override
  State<AnchorListPage> createState() => _AnchorListPageState();
}

class _AnchorListPageState extends State<AnchorListPage>
    with SingleTickerProviderStateMixin {
  BuildContext? _sliverListViewContext;
  late TabController _tabController;
  List tabs = ["News(0)", "History(5)", "Picture(10)"];
  List<int> tabIndexs = [0, 5, 10];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anchor ListView"),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 44),
          child: IgnorePointer(
            child: TabBar(
              controller: _tabController,
              tabs: tabs.map((e) => Tab(text: e)).toList(),
              onTap: (index) {},
            ),
          ),
        ),
      ),
      body: ListViewObserver(
        child: _buildListView(),
        sliverListContexts: () {
          return [if (_sliverListViewContext != null) _sliverListViewContext!];
        },
        onObserveAll: (resultMap) {
          final model = resultMap[_sliverListViewContext];
          if (model == null) return;

          final topIndex = model.firstChild?.index ?? 0;
          final index = tabIndexs.indexOf(topIndex);
          if (index != -1) {
            _tabController.index = index;
          } else {
            var targetTabIndex = _tabController.index - 1;
            if (targetTabIndex < 0 || targetTabIndex >= tabIndexs.length) {
              return;
            }
            var curIndex = tabIndexs[_tabController.index];
            var lastIndex = tabIndexs[_tabController.index - 1];
            if (curIndex > topIndex && lastIndex < topIndex) {
              final lastTabIndex = tabIndexs.indexOf(lastIndex);
              if (lastTabIndex != -1) {
                _tabController.index = lastTabIndex;
              }
            }
          }
        },
      ),
    );
  }

  ListView _buildListView() {
    return ListView.separated(
      itemBuilder: (ctx, index) {
        _sliverListViewContext = ctx;
        return _buildListItemView(index);
      },
      separatorBuilder: (ctx, index) {
        return _buildSeparatorView();
      },
      itemCount: 50,
    );
  }

  Widget _buildListItemView(int index) {
    return Container(
      height: 300,
      color: Colors.black12,
      child: Center(
        child: Text(
          "index -- $index",
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Container _buildSeparatorView() {
    return Container(
      color: Colors.white,
      height: 5,
    );
  }
}
