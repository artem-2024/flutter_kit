import 'package:flutter/material.dart';

///
/// 虚线
///
class Separator extends StatelessWidget {
  final Color color;
  final Axis direction;
  final Size size;

  const Separator({
    Key? key,
    this.color = Colors.black,
    this.direction = Axis.horizontal,
    this.size = const Size(5.0, 1.0),
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final boxHeight = constraints.constrainHeight();
        final x = direction == Axis.horizontal ? boxWidth : boxHeight;
        final y = direction == Axis.horizontal ? size.width : size.height;
        final dashCount = (x / (2 * y)).floor();

        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: direction,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: size.width,
              height: size.height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
