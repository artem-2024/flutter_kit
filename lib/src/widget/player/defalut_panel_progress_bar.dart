import 'dart:math';

import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';
import '../../utils/screen_utils.dart';

/// 播放器进度条 + 时分秒显示
class DefaultPanelProgressBar extends StatelessWidget {
  const DefaultPanelProgressBar({
    Key? key,
    this.currentTime,
    this.duration,
    this.onSeek,
    this.onSliderChanged,
  }) : super(key: key);
  final int? currentTime;
  final int? duration;

  /// 控制 切换播放进度
  final ValueChanged<int>? onSeek;

  /// 控制 进度条被滑动
  final ValueChanged<int>? onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final isLandscape = ScreenUtils.isLandscape(context);
    var progressValue = max(0.0, (currentTime ?? 0.0).toDouble());
    final progressValueMax = (duration ?? 1.0).toDouble();
    const progressValueMin = 0.0;
    progressValue = min(max(progressValue, progressValueMin), progressValueMax);

    final currentDuration = Duration(seconds: currentTime ?? 1);
    final allDuration = Duration(seconds: duration ?? 1);
    final showHour = allDuration.inHours > 0;
    final currentHourStr = showHour
        ? '${currentDuration.inHours.toString().padLeft(2, '0')}:'
        : '';
    final allHourStr =
        showHour ? '${allDuration.inHours.toString().padLeft(2, '0')}:' : '';

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 横屏进度
          Offstage(
            offstage: (!isLandscape) || currentTime == null,
            child: SizedBox(
              width: showHour?102:82,
              child: Center(
                child: Text(
                  '$currentHourStr${currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Offstage(
              offstage: currentTime == null || duration == null,
              child: _BaseSlider(
                value: progressValue,
                // value: min(0.0,max(0.0,(widget.currentTime ?? 0.0).toDouble())),
                cacheValue: 0.0,
                min: progressValueMin,
                max: progressValueMax,
                colors: const _BaseSliderColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white60,
                  cursorColor: Colors.white,
                  baselineColor: Colors.white24,
                ),
                onChanged: (v) {
                  if (duration == null) return;
                  onSliderChanged?.call(v.toInt());
                },
                onChangeEnd: (v) async {
                  if (duration == null) return;
                  onSeek?.call(v.toInt());
                },
              ),
            ),
          ),

          // 竖屏进度/总时间
          Offstage(
            offstage: isLandscape || currentTime == null || duration == null,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: SizedBox(
                width: showHour ? 100 : 68,
                child: Text(
                  '$currentHourStr${currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}/$allHourStr${allDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${allDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),

          // 横屏总时间
          Offstage(
            offstage: (!isLandscape) || duration == null,
            child: SizedBox(
              width: showHour?102:82,
              child: Center(
                child: Text(
                  duration == null
                      ? '---'
                      : '$allHourStr${allDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${allDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
          ),

          // Offstage(
          //   offstage: widget.currentTime == null,
          //   child: SizedBox(
          //     width: showHour ? 43 : 29,
          //     child: Text(
          //       '$currentHourStr${currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
          //       style: const TextStyle(fontSize: 10, color: Colors.white),
          //     ),
          //   ),
          // ),
          // Offstage(
          //   offstage: widget.currentTime == null,
          //   child: const Text(
          //     '/',
          //     style: TextStyle(fontSize: 10, color: Colors.white),
          //   ),
          // ),
          // Offstage(
          //   offstage: widget.duration == null,
          //   child: SizedBox(
          //     width: showHour ? 43 : 29,
          //     child: Text(
          //       widget.duration == null
          //           ? '---'
          //           : '$allHourStr${allDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${allDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
          //       style: const TextStyle(fontSize: 10, color: Colors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// 播放器进度条
class _BaseSlider extends StatefulWidget {
  final double value;
  final double cacheValue;

  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  final _BaseSliderColors colors;

  const _BaseSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.cacheValue = 0.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.colors = const _BaseSliderColors(),
  })  : assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key);

  @override
  _BaseSliderState createState() {
    return _BaseSliderState();
  }
}

class _BaseSliderState extends State<_BaseSlider> {
  bool dragging = false;
  double dragValue = 0;
  static const double margin = 2.0;

  @override
  Widget build(BuildContext context) {
    final double num = widget.max - widget.min;
    var v = widget.value / num;
    var cv = widget.cacheValue / num;

    if (v.isNaN) {
      v = 0.0;
    }

    if (cv.isNaN) {
      cv = 0.0;
    }

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(left: margin, right: margin),
        height: double.infinity,
        width: double.infinity,
        color: Colors.transparent,
        child: CustomPaint(
          painter: _SliderPainter(v, cv, dragging, colors: widget.colors),
        ),
      ),
      onHorizontalDragStart: (DragStartDetails details) {
        if (dragging != true) {
          setState(() => dragging = true);
        }
        dragValue = widget.value;
        if (widget.onChangeStart != null) {
          widget.onChangeStart?.call(dragValue);
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        final box = context.findRenderObject() as RenderBox;
        final dx = details.localPosition.dx;
        dragValue = (dx - margin) / (box.size.width - 2 * margin);
        dragValue = max(0, min(1, dragValue));
        dragValue = dragValue * (widget.max - widget.min) + widget.min;
        widget.onChanged(dragValue);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (dragging != false) {
          setState(() => dragging = false);
        }
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd?.call(dragValue);
        }
      },
      onTapDown: (TapDownDetails details) {
        final globalPosition = details.globalPosition;
        final box = context.findRenderObject()! as RenderBox;
        final Offset tapPos = box.globalToLocal(globalPosition);
        final double relative = tapPos.dx / box.size.width;
        final sec = widget.max * relative;
        widget.onChanged.call(sec);
        widget.onChangeEnd?.call(sec);
      },
    );
  }
}

/// 播放器进度条绘制
class _SliderPainter extends CustomPainter {
  final double v;
  final double cv;

  final bool dragging;
  final Paint pt = Paint();

  final _BaseSliderColors colors;

  _SliderPainter(this.v, this.cv, this.dragging,
      {this.colors = const _BaseSliderColors()});

  @override
  void paint(Canvas canvas, Size size) {
    double lineHeight = min(size.height / 2, 2);
    pt.color = colors.baselineColor;
    double radius = min(size.height / 2, 8);
    // draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - lineHeight),
          Offset(size.width, size.height / 2 + lineHeight),
        ),
        Radius.circular(radius),
      ),
      pt,
    );

    final double value = v * size.width;

    // // draw played part
    pt.color = colors.playedColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - lineHeight),
          Offset(value, size.height / 2 + lineHeight),
        ),
        Radius.circular(radius),
      ),
      pt,
    );

    // draw cached part
    final double cacheValue = cv * size.width;
    if (cacheValue > value && cacheValue > 0) {
      pt.color = colors.bufferedColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(value, size.height / 2 - lineHeight),
            Offset(cacheValue, size.height / 2 + lineHeight),
          ),
          Radius.circular(radius),
        ),
        pt,
      );
    }

    if (dragging) {
      pt.color = Colors.white24;
      radius = min(size.height / 2, 12);
      canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
    }

    pt.color = colors.cursorColor;
    radius = min(size.height / 2, 7);
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);

    pt.color = colors.playedColor;
    radius = min(size.height / 2, 2.5);
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SliderPainter && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(v, cv, dragging, colors);

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return hashCode != oldDelegate.hashCode;
  }
}

/// 播放器样式
class _BaseSliderColors {
  const _BaseSliderColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.6),
    this.bufferedColor = const Color.fromRGBO(50, 50, 100, 0.4),
    this.cursorColor = const Color.fromRGBO(255, 0, 0, 0.8),
    this.baselineColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color cursorColor;
  final Color baselineColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BaseSliderColors &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode =>
      hashValues(playedColor, bufferedColor, cursorColor, baselineColor);
}
