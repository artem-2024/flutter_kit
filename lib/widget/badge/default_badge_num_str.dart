import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'default_badge.dart';

///
/// 数字字符徽章
///
class DefaultBadgeNumStr extends StatelessWidget {
  const DefaultBadgeNumStr({
    Key? key,
    required this.child,
    this.position = const BadgePosition(top: -12, end: -15),
    this.numStr,
    this.showBadge = true,
  }) : super(key: key);

  ///badge位置
  final BadgePosition position;

  ///子view
  final Widget child;

  ///初始化显示的字符
  final String? numStr;

  ///是否显示徽章 默认为显示
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return DefaultBadge(
      showBadge: showBadge,
      badge: buildBadgeNumStr(numStr),
      position: position,
      child: child,
    );
  }

  ///数字字符
  static Widget buildBadgeNumStr(String? badgeStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 0.5),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(6.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffff725b),
            Color(0xffff4040),
          ],
        ),
      ),
      child: Center(
        child: Text(
          badgeStr ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 10),
          maxLines: 1,
        ),
      ),
    );
  }
}
