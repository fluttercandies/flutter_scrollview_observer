/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class AnchorListPage extends StatefulWidget {
  const AnchorListPage({Key? key}) : super(key: key);

  @override
  State<AnchorListPage> createState() => _AnchorListPageState();
}

class _AnchorListPageState extends State<AnchorListPage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;
  late TabController _tabController;
  List tabs = ["News(0)", "History(5)", "Picture(10)"];
  List<int> tabIndexs = [0, 5, 10];

  @override
  void initState() {
    super.initState();
    observerController = ListObserverController(controller: scrollController);
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anchor ListView"),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 44),
          child: TabBar(
            controller: _tabController,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
            onTap: (index) {
              observerController.animateTo(
                index: tabIndexs[index],
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
              );
            },
          ),
        ),
      ),
      body: ListViewObserver(
        controller: observerController,
        child: _buildListView(),
        onObserve: (resultModel) {
          _tabController.index = ObserverUtils.calcAnchorTabIndex(
            observeModel: resultModel,
            tabIndexs: tabIndexs,
            currentTabIndex: _tabController.index,
          );
        },
      ),
    );
  }

  ListView _buildListView() {
    return ListView.separated(
      controller: scrollController,
      itemBuilder: (ctx, index) {
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
