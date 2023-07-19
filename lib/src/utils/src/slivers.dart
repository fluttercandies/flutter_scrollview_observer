import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverObserveContextToBoxAdapter extends SliverToBoxAdapter {
  final void Function(BuildContext) onObserve;

  const SliverObserveContextToBoxAdapter({
    Key? key,
    required Widget? child,
    required this.onObserve,
  }) : super(key: key, child: child);

  @override
  RenderSliverToBoxAdapter createRenderObject(BuildContext context) {
    onObserve.call(context);
    return super.createRenderObject(context);
  }
}
