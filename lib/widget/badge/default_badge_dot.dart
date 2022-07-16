import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'default_badge.dart';

///
/// 圆点徽章
///
class DefaultBadgeDot extends StatelessWidget {
  const DefaultBadgeDot({
    Key? key,
    required this.child,
    this.position = const BadgePosition(top: -10, end: -10),
    this.showBadge = true,
  }) : super(key: key);

  ///badge位置
  final BadgePosition position;

  ///子view
  final Widget child;

  ///是否显示徽章
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    ///默认的小红点位置
    return DefaultBadge(
      showBadge: showBadge,
      badge: buildBadgeDotContent(),
      position: position,
      child: child,
    );
  }

  ///圆点
  static Widget buildBadgeDotContent() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEB6858),
        boxShadow: [
          BoxShadow(
              color: Color(0xFFEB6858), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
    );
  }
}
