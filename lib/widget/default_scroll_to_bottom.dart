import 'package:flutter/material.dart';

/// 滚动列表到底部
void scrollListToBottom(ScrollController scrollController,
    {bool inverted = false,
    double paddingHeight = 60.0,
    bool animate = true,
    int animateMilliseconds = 300}) {
  final offset = inverted
      ? 0.0
      : scrollController.position.maxScrollExtent + paddingHeight;
  if (animate) {
    scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: animateMilliseconds),
      curve: Curves.easeInOut,
    );
  } else {
    scrollController.jumpTo(offset);
  }
}

/// 默认的返回底部按钮容器
class DefaultScrollToBottomContainer extends StatelessWidget {
  const DefaultScrollToBottomContainer({
    Key? key,
    this.onTap,
    required this.child,
  }) : super(key: key);
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          boxShadow:  [
            BoxShadow(
              color: const Color(0xff48A1EC).withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 2),
            )
          ],
          gradient: const LinearGradient(
            colors: [
              Color(0xff006CFF),
              Color(0xff31D6FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
