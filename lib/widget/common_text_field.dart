import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_app/config/build_config.dart';

import 'image/default_image.dart';

///
/// 通用的输入框
///
class CommonTextField extends StatefulWidget {
  const CommonTextField({
    Key? key,
    this.textEditingController,
    this.focusNode,
    this.inputFormatters,
    this.textInputAction,
    this.keyboardType,
    this.otherSuffix,
    this.hintText = '',
    this.obscureText = false,
    this.showCleanSuffix = true,
    this.height = 44,
    this.margin,
    this.maxLength = 300,
    this.onChanged,
    this.style = const CommonTextFieldStyle.light(),
    this.otherLeft,
    this.autofocus = false,
    this.decoration,
    this.fontSize = 14,
    this.onSubmitted,
    this.horizontalPadding = 16,
    this.clearOnSubmitted = true,
  }) : super(key: key);
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;

  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;

  /// 额外的右侧widget
  final Widget? otherSuffix;

  /// 额外的左侧widget
  final Widget? otherLeft;

  /// 是否显示清空输入的按钮
  final bool showCleanSuffix;

  /// 高度
  final double height;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 最大输入字符数
  final int maxLength;

  /// 输入内容发生改变
  final ValueChanged<String>? onChanged;

  /// 输入框样式
  final CommonTextFieldStyle style;

  /// 是否自动获取焦点 默认false
  final bool autofocus;

  /// 样式
  final Decoration? decoration;

  /// 文字大小
  final double fontSize;

  /// 提交动作
  final ValueChanged<String>? onSubmitted;

  /// 提交动作后是否清理输入内容
  final bool clearOnSubmitted;

  /// 内容水平间距
  final double horizontalPadding;


  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  /// 当前是否有焦点
  final ValueNotifier<bool> _hasFocus = ValueNotifier(false);

  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textEditingController =
        widget.textEditingController ?? TextEditingController();
    _focusNode.addListener(_focusNodeListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusNodeListener);
    if(widget.focusNode == null){
      _focusNode.dispose();
    }
    if(widget.textEditingController == null){
      _textEditingController.dispose();
    }
    _hasFocus.dispose();
    super.dispose();
  }
  /// 监听输入框焦点变化
  void _focusNodeListener() async {
    if (_focusNode.hasFocus) {
      _hasFocus.value = true;
    } else {
      _hasFocus.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.height,
      // 设置整体样式
      decoration: widget.decoration ??
          const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0xfff5f5f5),
              ),
            ),
          ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          widget.otherLeft ?? const SizedBox.shrink(),
          Expanded(
            child: TextField(
              autofocus: widget.autofocus,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.style.textColor,
                letterSpacing: 1.2,
              ),
              inputFormatters: widget.inputFormatters,
              focusNode: _focusNode,
              // textAlignVertical: TextAlignVertical.center,
              textInputAction: widget.textInputAction,
              controller: _textEditingController,
              keyboardType: widget.keyboardType,
              onChanged: (content) {
                widget.onChanged?.call(content);
              },
              obscureText: widget.obscureText,
              maxLines: 1,
              maxLength: widget.maxLength,
              cursorColor: widget.style.cursorColor,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: widget.fontSize,
                  color: widget.style.hintTextColor,
                ),
                counter: null,
                counterText: '',
                hintMaxLines: 1,
              ),
              onSubmitted: (text) {
                if (widget.onSubmitted == null) return;
                // if (text.isNotEmpty != true) return;
                if(widget.clearOnSubmitted){
                  _textEditingController.clear();
                }
                widget.onSubmitted!.call(text);
              },
            ),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: _hasFocus,
              builder: (_, hasFocus, child) {
                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _textEditingController,
                  builder: (_, textEditingValue, child) {
                    return Offstage(
                      offstage: !widget.showCleanSuffix  || !hasFocus || textEditingValue.text.isEmpty,
                      child: child,
                    );
                  },
                  child: IconButton(
                    onPressed: () {
                      _textEditingController.clear();
                      widget.onChanged?.call('');
                    },
                    icon: DefaultAssetImage(
                      'assets/images/icon_clean.png',
                      width: 18,
                      height: 18,
                      color: widget.style.iconColor,
                    ),
                  ),
                );
              }),
          widget.otherSuffix ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

///
/// 通用的密码输入框
///
class CommonPwdTextField extends StatefulWidget {
  const CommonPwdTextField({
    Key? key,
    this.margin,
    this.textEditingController,
    this.focusNode,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.hintText = '请输入密码',
    this.style = const CommonTextFieldStyle.light(),
    this.otherLeft,
    this.autofocus = false,
    this.horizontalPadding = 16,
  }) : super(key: key);

  /// 外边距
  final EdgeInsetsGeometry? margin;
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final TextInputAction? textInputAction;

  /// 额外的左侧widget
  final Widget? otherLeft;

  /// 输入框样式
  final CommonTextFieldStyle style;

  /// 是否自动获取焦点 默认false
  final bool autofocus;

  /// 内容水平间距
  final double horizontalPadding;

  @override
  _CommonPwdTextFieldState createState() => _CommonPwdTextFieldState();
}

class _CommonPwdTextFieldState extends State<CommonPwdTextField> {
  /// 密码是否明文显示
  late final ValueNotifier<bool> _showPwd = ValueNotifier(false);

  @override
  void dispose() {
    _showPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showPwd,
      builder: (_, isShowPwd, __) {
        return CommonTextField(
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9A-Z]'))
          ],
          keyboardType: TextInputType.visiblePassword,
          horizontalPadding: widget.horizontalPadding,
          autofocus: widget.autofocus,
          otherLeft: widget.otherLeft,
          style: widget.style,
          margin: widget.margin,
          textEditingController: widget.textEditingController,
          focusNode: widget.focusNode,
          obscureText: !isShowPwd,
          textInputAction: widget.textInputAction,
          hintText: widget.hintText,
          showCleanSuffix: false,
          maxLength: 12,
          otherSuffix: IconButton(
            iconSize: 18,
            onPressed: () {
              _showPwd.value = !_showPwd.value;
            },
            icon: DefaultAssetImage(
              isShowPwd == true
                  ? 'assets/images/icon_eyes_open.png'
                  : 'assets/images/icon_eyes_close.png',
              width: 18,
              height: 18,
            ),
          ),
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

/// 输入栏左侧文本 （eg:确认新密码：）
class CommonTextFieldLeftTextWidget extends StatelessWidget {
  const CommonTextFieldLeftTextWidget(
    this.text, {
    Key? key,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);
  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: ColorHelper.colorTextBlack1,
        ),
      ),
    );
  }
}

/// 输入框样式
class CommonTextFieldStyle {
  final Color textColor;
  final Color hintTextColor;
  final Color cursorColor;
  final Color? iconColor;

  const CommonTextFieldStyle.dart({
    this.hintTextColor = Colors.white60,
    this.textColor = Colors.white,
    this.cursorColor = Colors.white,
    this.iconColor,
  });

  const CommonTextFieldStyle.light({
    this.hintTextColor = ColorHelper.colorTextBlack2,
    this.textColor = ColorHelper.colorTextBlack1,
    this.cursorColor = ColorHelper.colorTheme,
    this.iconColor = ColorHelper.colorTextBlack2,
  });
}
/*

    中文输入法统计正在编辑中文的过程中会统计英文，假如限制5个中文，当输入4个中文后，最后一个中文输入2个及以上英文时，会触发最大字数限制

int _wordLength = 0;
  /// 计算字数，不算正在编辑的文字
  void _computeWordCount() {
    var valueLength = _controller.value.text.length;
    var composingLength =
        _controller.value.composing.end - _controller.value.composing.start;
    setState(() {
      _wordLength = valueLength - composingLength;
    });
  }


TextField(
  controller: _controller,
  onChanged: (value){
    _computeWordCount();
  },
  decoration: InputDecoration(
      counterText: '$_wordLength/32'
  ),
),
*/
