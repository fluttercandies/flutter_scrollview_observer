/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class ListViewDynamicOffsetPage extends StatefulWidget {
  const ListViewDynamicOffsetPage({Key? key}) : super(key: key);

  @override
  State<ListViewDynamicOffsetPage> createState() =>
      _ListViewDynamicOffsetPageState();
}

class _ListViewDynamicOffsetPageState extends State<ListViewDynamicOffsetPage> {
  BuildContext? _sliverListViewContext;

  int _hitIndex = 0;

  double _safeAreaPaddingTop = 0;

  final double _navContentHeight = 44;

  double _navBgAlpha = 0;

  bool _isShowNavTitle = false;

  final ScrollController _pageController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageDidScroll);

    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      _safeAreaPaddingTop = MediaQuery.of(context).padding.top;

      // Trigger an observation manually
      ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageDidScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListViewObserver(
            child: _buildListView(),
            sliverListContexts: () {
              return [
                if (_sliverListViewContext != null) _sliverListViewContext!
              ];
            },
            dynamicLeadingOffset: () {
              if (_navBgAlpha < 1) {
                return 0;
              }
              return _safeAreaPaddingTop + _navContentHeight;
            },
            onObserveAll: (resultMap) {
              final model = resultMap[_sliverListViewContext];
              if (model == null) return;

              debugPrint('firstChild.index -- ${model.firstChild?.index}');
              debugPrint('displaying -- ${model.displayingChildIndexList}');

              setState(() {
                _hitIndex = model.firstChild?.index ?? 0;
              });
            },
          ),
          Container(
            color: Colors.grey.withValues(alpha: _navBgAlpha),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  bottom: false,
                  child: _buildNavContentWidget(context),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListView _buildListView() {
    return ListView.separated(
      controller: _pageController,
      padding: EdgeInsets.zero,
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

  Widget _buildListItemView(int index) {
    return Container(
      height: (index % 2 == 0) ? 80 : 50,
      color: _hitIndex == index ? Colors.red : Colors.black12,
      child: Center(
        child: Text(
          "index -- $index",
          style: TextStyle(
            color: _hitIndex == index ? Colors.white : Colors.black,
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

  Widget _buildNavContentWidget(BuildContext context) {
    return Container(
      height: _navContentHeight,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: _isShowNavTitle ? Colors.black : Colors.white,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                "ListView Dynnamic Offset",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54.withValues(
                    alpha: _isShowNavTitle ? 1 : 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pageDidScroll() {
    final offset = _pageController.offset;
    double _newNavBgAlpha = 0;
    if (offset < 0) {
      _newNavBgAlpha = 0;
    } else if (offset >= _navContentHeight) {
      _newNavBgAlpha = 1;
    } else {
      _newNavBgAlpha = offset / _navContentHeight;
    }
    if (_navBgAlpha != _newNavBgAlpha) {
      setState(() {
        _navBgAlpha = _newNavBgAlpha;
        _isShowNavTitle = _navBgAlpha > .5;
      });
    }
  }
}
