import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

///
/// 徽章widget
///
class DefaultBadge extends StatelessWidget {
  const DefaultBadge({
    Key? key,
    required this.child,
    required this.badge,
    this.position = const BadgePosition(top: -12, end: -12),
    this.showBadge = true,
  }) : super(key: key);

  ///徽章 可以是点、图片、数字文本等各种widget
  final Widget badge;

  ///badge位置
  final BadgePosition position;

  ///子view
  final Widget child;

  ///是否显示徽章
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      showBadge: showBadge,
      badgeColor: Colors.transparent,
      elevation: 0,
      position: position,
      badgeContent: badge,
      child: child,
    );
  }
}
