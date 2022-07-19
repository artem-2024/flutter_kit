import 'package:flutter/material.dart';

///
/// 具备变换动画的的容器
///
///  eg：当Scaffold.resizeToAvoidBottomInset为false时可以获取软键盘高度
///  可以通过 final keyboardHeight = MediaQuery.of(context).viewInsets.bottom
///  然后 dy = -keyboardHeight  可以实现输入法弹出时整体布局上移，如全屏时的输入框
///
class TransformContainer extends StatelessWidget {
  const TransformContainer({
    Key? key,
    required this.y,
    required this.child,
  }) : super(key: key);
  final double y;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedContainer(
        color: Colors.transparent,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, y, 0),
        child: child,
      ),
    );
  }
}
