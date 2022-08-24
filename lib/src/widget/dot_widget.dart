import 'package:flutter/material.dart';

/// 圆点
class DotWidget extends StatelessWidget {
  const DotWidget({
    Key? key,
    this.size = 7,
    this.color,
  }) : super(key: key);
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
