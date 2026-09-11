import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

class SliverObserveContext extends SliverPadding {
  final void Function(BuildContext) onObserve;
  const SliverObserveContext({
    super.key,
    Widget? child,
    required this.onObserve,
  }) : super(padding: EdgeInsets.zero, sliver: child);

  @override
  RenderSliverPadding createRenderObject(BuildContext context) {
    onObserve.call(context);
    return super.createRenderObject(context);
  }
}

class SliverObserveContextToBoxAdapter extends SliverToBoxAdapter {
  final void Function(BuildContext) onObserve;

  const SliverObserveContextToBoxAdapter({
    super.key,
    required super.child,
    required this.onObserve,
  });

  @override
  RenderSliverToBoxAdapter createRenderObject(BuildContext context) {
    onObserve.call(context);
    return super.createRenderObject(context);
  }
}
