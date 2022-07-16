import 'package:flutter/material.dart';

class ScaleAnimation extends StatefulWidget {
  /// 停止动画
  final bool stopAnimation;

  /// 子类控件
  final Widget child;

  const ScaleAnimation({
    Key? key,
    required this.child,
    this.stopAnimation = false,
  }) : super(key: key);

  @override
  _ScaleAnimationState createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation> with SingleTickerProviderStateMixin {
  /// 动画所需控制器
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn)),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stopAnimation == true) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _animationController,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return ScaleTransition(
          alignment: Alignment.center,
          scale: CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
          child: child,
        );
      },
    );
  }
}
