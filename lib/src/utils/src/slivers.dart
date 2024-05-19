import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverObserveContext extends SliverPadding {
  final void Function(BuildContext) onObserve;
  const SliverObserveContext({
    Key? key,
    Widget? child,
    required this.onObserve,
  }) : super(
          key: key,
          padding: EdgeInsets.zero,
          sliver: child,
        );

  @override
  RenderSliverPadding createRenderObject(BuildContext context) {
    onObserve.call(context);
    return super.createRenderObject(context);
  }
}

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
