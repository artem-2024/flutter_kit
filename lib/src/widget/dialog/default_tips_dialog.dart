import 'package:flutter/material.dart';



/// 展示Material风格的提示dialog
Future<bool?> showDefaultTipsDialog(
  BuildContext context, {
  String? contentText,
  String title = '温馨提示',
  VoidCallback? confirm,
  VoidCallback? cancel,
  Widget? contentWidget,
  String confirmText = '确认',
  String cancelText = '取消',
  bool barrierDismissible = true,
  bool justShowConfirm = false,
}) {
  // 处理如果页面有输入框，且由于输入框仍然有焦点，关掉对话框，否则软键盘又会自动弹起的问题
  FocusManager.instance.primaryFocus?.unfocus();
  return showDialog<bool?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      // 取消动作
      final cancelAction = TextButton(
        child: Text(cancelText),
        onPressed: () {
          Navigator.maybePop(context, false);
          cancel?.call();
        },
      );

      // 确定动作
      final confirmAction = TextButton(
        child: Text(confirmText),
        onPressed: () {
          Navigator.pop(context, true);
          confirm?.call();
        },
      );

      return AlertDialog(
        title: Text(title),
        content: contentWidget ??
            (contentText?.trim().isNotEmpty == true
                ? Text(contentText ?? '')
                : null),
        actions:
            justShowConfirm ? [confirmAction] : [cancelAction, confirmAction],
      );
    },
  );
}


/// 展示自定义风格的提示dialog
Future<bool?> showThemeTipsDialog(
    BuildContext context, {
      String? contentText,
      String title = '温馨提示',
      VoidCallback? confirm,
      VoidCallback? cancel,
      Widget? contentWidget,
      String confirmText = '确认',
      String cancelText = '取消',
      bool barrierDismissible = true,
      bool justShowConfirm = false,
    }) {
  // 处理如果页面有输入框，且由于输入框仍然有焦点，关掉对话框，否则软键盘又会自动弹起的问题
  FocusManager.instance.primaryFocus?.unfocus();
  return showDialog<bool?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      // 取消动作
      final cancelAction = DialogActionBtn(
        text: cancelText,
        onTap: () {
          Navigator.maybePop(context, false);
          cancel?.call();
        },
      );

      // 确定动作
      final confirmAction = DialogActionBtn(
        text: confirmText,
        onTap: () {
          Navigator.pop(context, true);
          confirm?.call();
        },
      );

      final actions = justShowConfirm ? [confirmAction] : [ confirmAction,const SizedBox(width: 6.5,),cancelAction];
      final content = contentWidget ??
          (contentText?.trim().isNotEmpty == true
              ? Text(contentText ?? '',textAlign: TextAlign.center,)
              : null)??const SizedBox();
      return Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if(barrierDismissible){
              Navigator.pop(context);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children:  [
              Container(
                width: 297.5,
                padding: const EdgeInsets.only(left: 15,right: 15,top:40,bottom: 30),
                decoration:  BoxDecoration(
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/dialog_tips_bg.png',package: 'flutter_kit')
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(height: 21),
                    content,
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class DialogActionBtn extends StatelessWidget {
  const DialogActionBtn({super.key,required this.text,this.onTap});
  final String text;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 47,vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xffCACACA),width: 0.5)
        ),
        child: Text(text),
      ),
    );
  }
}


