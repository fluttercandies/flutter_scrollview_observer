/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-05-29 22:22:07
 */

import 'package:material_ui/material_ui.dart';

class SlideAnimation extends StatelessWidget {
  final Curve curve;

  final double verticalOffset;

  final double horizontalOffset;

  final Widget child;

  final AnimationController controller;

  const SlideAnimation({
    super.key,
    this.curve = Curves.ease,
    required this.controller,
    double? verticalOffset,
    double? horizontalOffset,
    required this.child,
  }) : verticalOffset = verticalOffset ?? 0.0,
       horizontalOffset = horizontalOffset ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return AnimationExecutor(
      controller: controller,
      builder: (context, animationController) =>
          _slideAnimation(animationController!),
    );
  }

  Widget _slideAnimation(Animation<double> animation) {
    Animation<double> offsetAnimation(
      double offset,
      Animation<double> animation,
    ) {
      return Tween<double>(begin: offset, end: 0.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 1.0, curve: curve),
        ),
      );
    }

    return Transform.translate(
      offset: Offset(
        horizontalOffset == 0.0
            ? 0.0
            : offsetAnimation(horizontalOffset, animation).value,
        verticalOffset == 0.0
            ? 0.0
            : offsetAnimation(verticalOffset, animation).value,
      ),
      child: child,
    );
  }
}

class FadeInAnimation extends StatelessWidget {
  final Curve curve;

  final Widget child;

  final AnimationController controller;

  const FadeInAnimation({
    super.key,
    this.curve = Curves.ease,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationExecutor(
      controller: controller,
      builder: (context, animationController) =>
          _fadeInAnimation(animationController!),
    );
  }

  Widget _fadeInAnimation(Animation<double> animation) {
    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(0.0, 1.0, curve: curve),
      ),
    );

    return Opacity(opacity: opacityAnimation.value, child: child);
  }
}

typedef Builder = Widget Function(
  BuildContext context,
  AnimationController? animationController,
);

class AnimationExecutor extends StatefulWidget {
  final Builder builder;
  final AnimationController controller;

  const AnimationExecutor({
    super.key,
    required this.builder,
    required this.controller,
  });

  @override
  State<AnimationExecutor> createState() => _AnimationExecutorState();
}

class _AnimationExecutorState extends State<AnimationExecutor>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: widget.controller,
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return widget.builder(context, widget.controller);
  }
}
