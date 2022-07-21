import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';

/// 展示默认风格的提示dialog
Future<bool?> showDefaultTipsDialog(
  BuildContext context, {
  String? contentText,
  String title = '温馨提示',
  VoidCallback? confirm,
  VoidCallback? cancel,
  Widget? contentWidget,
  Color confirmTextColor = ColorHelper.colorTextTheme,
  String confirmText = '确认',
  String cancelText = '取消',
  bool barrierDismissible = true,
  bool justShowConfirm = false,
}) async {
  // 处理如果页面有输入框，且由于输入框仍然有焦点，关掉对话框，软键盘又会自动弹起的问题
  FocusManager.instance.primaryFocus?.unfocus();
  return await showDialog(
    barrierColor: const Color.fromRGBO(52, 52, 52, 0.6),
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      final cancelAction = CupertinoDialogAction(
        child: Text(
          cancelText,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff99A2AB),
          ),
        ),
        onPressed: () {
          Navigator.maybePop(context, false);
          cancel?.call();
        },
      );
      final confirmAction = CupertinoDialogAction(
        child: Text(
          confirmText,
          style: TextStyle(
            fontSize: 14,
            color: confirmTextColor,
          ),
        ),
        onPressed: () {
          Navigator.pop(context, true);
          confirm?.call();
        },
      );

      return CupertinoAlertDialog(
        title: Text(title),
        content: Container(
          margin: const EdgeInsets.only(top: 12),
          child: contentWidget ??
              Text(
                contentText ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorHelper.colorTextBlack1,
                  fontWeight: fontWeight,
                ),
              ),
        ),
        insetAnimationDuration: const Duration(milliseconds: 350),
        actions:
            justShowConfirm ? [confirmAction] : [cancelAction, confirmAction],
      );
    },
  );
}
