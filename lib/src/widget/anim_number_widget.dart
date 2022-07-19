import 'package:flutter/material.dart';

/// 显示文本格式化
typedef NumberFormatFunc = String Function(double number);

/// 带滚动效果的数字组件
class AnimNumberWidget extends StatefulWidget {
  final Duration numberAnimationDuration;
  final num number;
  final NumberFormatFunc? formatFunc;

  const AnimNumberWidget({
    Key? key,
    this.number = 0.0,
    this.numberAnimationDuration = const Duration(milliseconds: 200),
    this.formatFunc,
  }) : super(key: key);

  @override
  AnimNumberWidgetState createState() => AnimNumberWidgetState();
}

class AnimNumberWidgetState extends State<AnimNumberWidget>
    with TickerProviderStateMixin {
  late double _number;
  late double _preNumber;
  late AnimationController _numberController;
  late Animation<Offset> _slidePreValueAnimation;
  late Animation<Offset> _slideCurrentValueAnimation;
  late Animation<double> _opacityAnimation;

  double get nowNumber => _number;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    _number = widget.number.toDouble();
    _preNumber = _number;

    _numberController = AnimationController(
        duration: widget.numberAnimationDuration, vsync: this);

    _initAnimations();
  }

  /*@override
  void didUpdateWidget(Widget oldWidget) {
    init();
    super.didUpdateWidget(oldWidget);
  }*/
  void _initAnimations() {
    _slidePreValueAnimation = _numberController.drive(Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1.0),
    ));
    _slideCurrentValueAnimation = _numberController.drive(Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ));

    _opacityAnimation = _numberController.drive(Tween<double>(
      begin: 0.0,
      end: 1.0,
    ));
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _getNumberWidget(),
      ],
    );

    /*return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: doStep,
      child: childWidget,
      */ /*child: Container(
        width: 100,
        height: 40,
        child: childWidget,
      ),*/ /*
    );*/
    return childWidget;
  }

  ///执行动画
  ///isAdd 默认是增加
  void doStep({double stepNum = 1.0, bool isAdd = true}) {
    if (_numberController.isAnimating) return;

    _preNumber = _number;
    if (isAdd == true) {
      _number += stepNum;
    } else {
      _number -= stepNum;
    }
    if (mounted) {
      setState(() {
        _numberController.reset();
        _numberController.forward();
      });
    }
  }

  //格式化
  String _formatNumberStr(double number) {
    var tmpNumberStr = '0.0';
    tmpNumberStr = number.toString();
    return tmpNumberStr;
  }

  Widget _getNumberWidget() {
    late String number, preNumber;
    if (widget.formatFunc != null) {
      number = widget.formatFunc!(_number);
      preNumber = widget.formatFunc!(_preNumber);
    } else {
      number = _formatNumberStr(_number);
      preNumber = _formatNumberStr(_preNumber);
    }
    int didIndex = 0;
    if (preNumber.length == number.length) {
      for (; didIndex < number.length; didIndex++) {
        if (number[didIndex] != preNumber[didIndex]) {
          break;
        }
      }
    }
    bool allChange = preNumber.length != number.length || didIndex == 0;

    Widget result;

    if (!allChange) {
      var samePart = number.substring(0, didIndex);
      var preText = preNumber.substring(didIndex, preNumber.length);
      var text = number.substring(didIndex, number.length);
      var preSameWidget = _createNumberWidget(samePart);
      var currentSameWidget = _createNumberWidget(samePart);
      var preWidget = _createNumberWidget(preText);
      var currentWidget = _createNumberWidget(text);

      result = AnimatedBuilder(
          animation: _numberController,
          builder: (b, w) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.hardEdge, fit: StackFit.passthrough,
                  children: <Widget>[
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: currentSameWidget,
                    ),
                    Opacity(
                      opacity: 1.0 - _opacityAnimation.value,
                      child: preSameWidget,
                    ),
                  ],
                ),
                Stack(
                  clipBehavior: Clip.hardEdge, fit: StackFit.passthrough,
                  children: <Widget>[
                    FractionalTranslation(
                        translation: _preNumber > _number
                            ? _slideCurrentValueAnimation.value
                            : -_slideCurrentValueAnimation.value,
                        child: currentWidget),
                    FractionalTranslation(
                        translation: _preNumber > _number
                            ? _slidePreValueAnimation.value
                            : -_slidePreValueAnimation.value,
                        child: preWidget),
                  ],
                )
              ],
            );
          });
    } else {
      result = AnimatedBuilder(
        animation: _numberController,
        builder: (b, w) {
          return Stack(
            clipBehavior: Clip.hardEdge, fit: StackFit.passthrough,
            children: <Widget>[
              FractionalTranslation(
                  translation: _preNumber > _number
                      ? _slideCurrentValueAnimation.value
                      : -_slideCurrentValueAnimation.value,
                  child: _createNumberWidget(_number.toString())),
              FractionalTranslation(
                  translation: _preNumber > _number
                      ? _slidePreValueAnimation.value
                      : -_slidePreValueAnimation.value,
                  child: _createNumberWidget(_preNumber.toString())),
            ],
          );
        },
      );
    }

    result = ClipRect(
      clipper: TheNumberClip(),
      child: result,
    );

    return result;
  }

  Widget _createNumberWidget(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.red),
    );
  }
}

class TheNumberClip extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Offset.zero & size;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
