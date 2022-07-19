import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  /// 动画控制器
  final AnimationController animationController;

  /// 停止动画
  final bool stopAnimation;

  /// 如果child使用的是list等之类的列表就需要确定子类的长度
  final int length;

  /// 如果child使用的是list等之类的列表就需要确定子类，根据对应的index可以每个item不同的动画时间差
  final int index;

  /// 子类控件
  final Widget child;

  const FadeAnimation({
    Key? key,
    required this.animationController,
    this.length = 1,
    this.index = 0,
    required this.child,
    this.stopAnimation = false,
  })  : assert(length > 0),
        assert(index >= 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stopAnimation == true) {
      return child;
    }
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval((1 / length) * index, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    animationController.forward();
    return AnimatedBuilder(
      animation: animationController,
      child: child,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 50 * (1.0 - animation.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }
}
