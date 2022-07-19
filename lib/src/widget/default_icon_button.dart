import 'package:flutter/material.dart';

import 'image/default_image.dart';

/// 单个图标按钮
class DefaultIconButton extends StatelessWidget {
  const DefaultIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size = 28,
  }) : super(key: key);
  final String icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: onPressed,
      icon: DefaultAssetImage(
        icon,
        width: size,
        height: size,
      ),
    );
  }
}
