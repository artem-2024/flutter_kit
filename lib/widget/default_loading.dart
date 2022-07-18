import 'package:flutter/material.dart' hide ProgressIndicator;
import '../flutter/progress_indicator.dart' as extend;
import '../flutter_kit.dart';
///
/// 默认的圆形进度条
///
class DefaultCircularProgressIndicator extends StatelessWidget {
  const DefaultCircularProgressIndicator({
    Key? key,
    this.size,
    this.isCenter,
  }) : super(key: key);
  final double? size;
  final bool? isCenter;

  @override
  Widget build(BuildContext context) {
    Widget child = const extend.CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        ColorHelper.colorTextTheme,
      ),
    );
    if (size != null) {
      child = SizedBox(
        width: size,
        height: size,
        child: child,
      );
    }
    if (isCenter == true) {
      child = Center(child: child);
    }
    return child;
  }
}

///
/// 默认的加载框
///
class DefaultLoading extends StatelessWidget {
  /// 提醒文本
  final String title;

  const DefaultLoading({
    Key? key,
    this.title = defaultLoadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                width: 21,
                height: 21,
                child: DefaultCircularProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 9,
                  left: 2,
                  right: 2,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
