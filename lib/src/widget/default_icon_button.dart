import 'package:flutter/material.dart';

import 'image/default_image.dart';

/// 单个图标按钮
class DefaultIconButton extends StatelessWidget {
  const DefaultIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size = 28,
    this.heightSize,
  }) : super(key: key);
  final String icon;
  final VoidCallback? onPressed;
  final double size;
  final double? heightSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: onPressed,
      icon: DefaultAssetImage(
        icon,
        width: size,
        height: heightSize??size,
      ),
    );
  }
}
