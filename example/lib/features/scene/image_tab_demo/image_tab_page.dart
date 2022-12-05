/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-22 22:17:55
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class ImageTabPage extends StatefulWidget {
  const ImageTabPage({Key? key}) : super(key: key);

  @override
  State<ImageTabPage> createState() => _ImageTabPageState();
}

class _ImageTabPageState extends State<ImageTabPage> {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ScrollController scrollController = ScrollController();
  late ListObserverController observerController;
  double screenWidth = 0;

  List<String> imgUrlList = [
    'photo-1660806982611-0a41c0527966',
    'photo-1660032356057-efd3e1eb045c',
    'photo-1660139099083-03e0777ac6a7',
    'photo-1659030320611-9d23ca40e29e',
    'photo-1658858288004-42989dac61a2',
    'photo-1647238384941-adfd9288341b',
    'photo-1651054558996-03455fe2702f',
    'photo-1655704705321-3ac52dc67f70',
    'photo-1654250910768-0162e080ef86',
    'photo-1652956815155-5c54d1fc40a9',
  ];

  @override
  void initState() {
    super.initState();
    observerController = ListObserverController(controller: scrollController);
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("ImageTab")),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 300,
            child: ValueListenableBuilder<int>(
              builder: (BuildContext context, int value, Widget? child) {
                return _buildImageWidget(value);
              },
              valueListenable: selectedIndex,
            ),
          ),
          const SizedBox(height: 10),
          _buildImageTabBar(),
        ],
      ),
    );
  }

  Widget _buildImageTabBar() {
    Widget resultWidget = ListViewObserver(
      controller: observerController,
      child: ListView.separated(
        controller: scrollController,
        itemBuilder: (ctx, index) {
          return _buildListItemView(index);
        },
        separatorBuilder: (ctx, index) {
          return _buildSeparatorView();
        },
        itemCount: imgUrlList.length,
        scrollDirection: Axis.horizontal,
      ),
    );
    resultWidget = SizedBox(
      height: 100,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListItemView(int index) {
    Widget imgWidget = _buildImageWidget(index);
    Widget resultWidget = ValueListenableBuilder<int>(
      builder: (BuildContext context, int value, Widget? child) {
        return Container(
          decoration: BoxDecoration(
            border: (selectedIndex.value == index)
                ? Border.all(color: Colors.orange, width: 3)
                : null,
          ),
          width: 80,
          height: 50,
          child: imgWidget,
        );
      },
      valueListenable: selectedIndex,
    );
    resultWidget = GestureDetector(
      child: resultWidget,
      onTap: () {
        debugPrint('index -- $index');
        selectedIndex.value = index;
        observerController.animateTo(
          index: index,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
          offset: (_) {
            return screenWidth * 0.5;
          },
        );
      },
    );
    return resultWidget;
  }

  Widget _buildImageWidget(int index) {
    return Image.network(
      _fetchImgUrl(index),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Container _buildSeparatorView() {
    return Container(
      color: Colors.white,
      width: 5,
    );
  }

  String _fetchImgUrl(int index) {
    return 'https://images.unsplash.com/' +
        imgUrlList[index] +
        '?auto=format&fit=crop&w=375&q=100';
  }
}
