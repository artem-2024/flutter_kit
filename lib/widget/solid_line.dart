import 'package:flutter/material.dart';

import '../flutter_kit.dart';

///
/// 实线
///
class SolidLine extends StatelessWidget {
  final Color color;
  final Axis direction;
  final Size size;
  final EdgeInsetsGeometry padding;

  const SolidLine.horizontal({
    Key? key,
    this.color = ColorHelper.colorLine,
    this.size = const Size(double.infinity, .5),
    this.padding = const EdgeInsets.all(0),
  })  : direction = Axis.horizontal,
        super(key: key);

  const SolidLine.vertical({
    Key? key,
    this.color = ColorHelper.colorLine,
    this.size = const Size(.5, double.infinity),
    this.padding = const EdgeInsets.all(0),
  })  : direction = Axis.vertical,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color),
        ),
      ),
    );
  }
}
