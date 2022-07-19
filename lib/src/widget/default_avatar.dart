import 'package:flutter/material.dart';

import 'image/default_image.dart';

/// 默认头像
class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({Key? key, this.width, this.height}) : super(key: key);
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: DefaultAssetImage(
        'assets/images/common/icon_ava_default.png',
        width: width,
        height: height,
      ),
    );
  }
}
