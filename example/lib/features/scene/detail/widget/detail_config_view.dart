/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-10 12:50:51
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic_config.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';

class DetailConfigView extends StatefulWidget {
  const DetailConfigView({super.key});

  @override
  State<DetailConfigView> createState() => _DetailConfigViewState();
}

class _DetailConfigViewState extends State<DetailConfigView>
    with DetailLogicConsumerMixin<DetailConfigView> {
  DetailState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailLogic>(
      tag: logicTag,
      id: DetailUpdateType.config,
      builder: (_) {
        Widget resultWidget = Column(
          children: [
            Expanded(
              child: _buildListView(),
            ),
            _buildConfirmBtn(),
          ],
        );
        resultWidget = SafeArea(
          top: false,
          child: resultWidget,
        );
        return resultWidget;
      },
    );
  }

  Widget _buildListView() {
    return ListView(
      children: [
        _buildDefaultAnchor(),
      ],
    );
  }

  Widget _buildDefaultAnchor() {
    return ListTile(
      title: const Text('Default Anchor'),
      trailing: DropdownMenu<DetailModuleType>(
        initialSelection: state.configSelectedAnchor,
        dropdownMenuEntries: state.configDefaultAnchorEntries,
        onSelected: (DetailModuleType? module) {
          if (module == null) return;
          state.configSelectedAnchor = module;
        },
      ),
    );
  }

  Widget _buildConfirmBtn() {
    Widget resultWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          logic.onConfigConfirm();
        },
        child: const Text('Confirm'),
      ),
    );
    return resultWidget;
  }
}
