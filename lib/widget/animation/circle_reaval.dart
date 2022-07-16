import 'dart:math';

import 'package:flutter/material.dart';

class CircleReveal extends StatelessWidget {
  const CircleReveal({
    Key? key,
    this.revealPercent = 0.0,
    required this.child,
    this.position = const Offset(0, 0),
  }) : super(key: key);

  /// 显示的百分比
  final double revealPercent;

  /// 控件
  final Widget child;

  /// 开始点
  final Offset position;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: _CircleRevealClipper(revealPercent, position),
      child: child,
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Rect> {
  /// 显示的百分比
  final double revealPercent;

  /// 开始的 xy轴位置
  final Offset position;

  const _CircleRevealClipper(this.revealPercent, this.position);

  @override
  Rect getClip(Size size) {
    final epicenter = position;

    double theta = atan(epicenter.dy / epicenter.dx);
    final distanceToCorner = epicenter.dy / sin(theta);

    final radius = distanceToCorner * revealPercent;
    final diameter = 2 * radius;

    return Rect.fromLTWH(
      epicenter.dx - radius,
      epicenter.dy - radius,
      diameter,
      diameter,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
