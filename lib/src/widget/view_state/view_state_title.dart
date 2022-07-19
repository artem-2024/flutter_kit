import 'package:flutter/material.dart';

///
/// 状态标题（eg，暂无相关数据、哎呀，网络开小差了）
///
class ViewStateTitle extends StatelessWidget {
  const ViewStateTitle(
    this.title, {
    Key? key,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xffD8DCDF),
      ),
    );
  }
}
