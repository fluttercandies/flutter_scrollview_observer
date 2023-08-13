/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-10 22:35:59
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/utils/random.dart';

class ScrollViewFormDemoPage extends StatefulWidget {
  const ScrollViewFormDemoPage({Key? key}) : super(key: key);

  @override
  State<ScrollViewFormDemoPage> createState() => _ScrollViewFormDemoPageState();
}

class _ScrollViewFormDemoPageState extends State<ScrollViewFormDemoPage> {
  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;

  final int formIndex = 3;

  FocusNode formFocusNode = FocusNode();

  List<String> imgUrlList = [
    'photo-1542317858-043bf4d34f9f',
    'photo-1472053217156-31b42df2319c',
    'photo-1643727349026-ba9c33acf10a',
    'photo-1615678857339-4e7e51ce22db',
    'photo-1647772809611-cd884d37de42',
    'photo-1505329603060-7c67cc801ee5',
    'photo-1627308722931-0e6a1214c03e',
    'photo-1556799483-e642a45aeb68',
  ];

  handleFormFocus() async {
    if (formFocusNode.hasFocus) {
      // Wait for the keyboard to fully display.
      await Future.delayed(const Duration(milliseconds: 560));
      // Trigger the observer to observe the ListView.
      final result = await observerController.dispatchOnceObserve(
        isForce: true,
        isDependObserveCallback: false,
      );
      if (!result.isSuccess) return;

      // Find the observation result for the form item.
      final formResultModel =
          result.observeResult?.displayingChildModelList.firstWhere((element) {
        return element.index == formIndex;
      });
      if (formResultModel == null) return;
      // Let the bottom of the form item view be fully displayed.
      observerController.controller?.animateTo(
        formResultModel.scrollOffset - formResultModel.trailingMarginToViewport,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    observerController = ListObserverController(controller: scrollController);
    formFocusNode.addListener(handleFormFocus);
  }

  @override
  void dispose() {
    formFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("ScrollView Form")),
      body: _buildScrollView(),
    );
  }

  Widget _buildScrollView() {
    Widget resultWidget = ListView.builder(
      controller: scrollController,
      itemBuilder: (context, index) {
        if (formIndex == index) {
          return _buildForm();
        }
        return _buildImage();
      },
      itemCount: 10,
    );
    resultWidget = ListViewObserver(
      controller: observerController,
      autoTriggerObserveTypes: const [],
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildForm() {
    Widget resultWidget = Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            focusNode: formFocusNode,
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10.0),
            child: TextButton(
              child: const Text('Submit'),
              onPressed: () {
                formFocusNode.unfocus();
              },
            ),
          ),
        ],
      ),
    );
    resultWidget = Container(
      color: Colors.green[100],
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildImage() {
    Widget resultWidget = Image.network(
      _fetchImgUrl(),
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
    resultWidget = Container(
      margin: const EdgeInsets.all(10),
      child: resultWidget,
    );
    return resultWidget;
  }

  String _fetchImgUrl() {
    return 'https://images.unsplash.com/' +
        imgUrlList[RandomTool.genInt(max: imgUrlList.length)] +
        '?auto=format&fit=crop&w=375&q=100';
  }
}
