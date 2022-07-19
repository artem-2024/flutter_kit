import 'package:flutter/material.dart';

import '../../flutter_kit.dart';

/// 圆点
class DotWidget extends StatelessWidget {
  const DotWidget({
    Key? key,
    this.color = ColorHelper.colorTextTheme,
    this.size = 7,
  }) : super(key: key);
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
