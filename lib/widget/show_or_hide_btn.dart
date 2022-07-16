import 'package:flutter/material.dart';
import 'package:lms_app/utils/gesture.dart';

import 'image/default_image.dart';

///
/// 查看更多 or 收起
///
class ShowOrHideBtn extends StatelessWidget {
  const ShowOrHideBtn({
    Key? key,
    this.height = 49,
    this.isHide = true,
    this.onTap,
  }) : super(key: key);

  /// 高度
  final double height;

  /// true代表当前可查看更多
  final bool isHide;

  /// 切换事件
  final ValueChanged<bool>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: GestureUtils.throttle(() => onTap?.call(!isHide)),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isHide ? '查看更多' : '收起',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff99A2AB),
              ),
            ),
            const SizedBox(width: 4),
            DefaultAssetImage(
              isHide
                  ? 'assets/images/common/icon_arrow_down.png'
                  : 'assets/images/common/icon_arrow_up.png',
              width: 8,
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
