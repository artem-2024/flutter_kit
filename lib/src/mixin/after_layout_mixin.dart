import 'package:flutter/widgets.dart';

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => afterFirstLayoutBuild(context));
  }

  /// 在页面第一次构建时候的回掉
  void afterFirstLayoutBuild(BuildContext context);
}
