import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';
import '../default_appbar.dart';
import 'component_empty_container.dart';

class EmptyDataContainer extends StatelessWidget {
  /// 标题
  final String title;


  final bool showHeader;

  final Color backgroundColor;

  const EmptyDataContainer({
    Key? key,
    this.title = emptyDataMessage,
    this.showHeader = false,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showHeader
          ? DefaultAppBar()
          : null,
      body: Center(
        child: ComponentEmptyContainer(title: title),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Image.asset(
        //       assetBundleUrl,
        //       width: 165,
        //       height: 100,
        //     ),
        //     const SizedBox(height: 20),
        //     ViewStateTitle(title),
        //   ],
        // ),
      ),
    );
  }
}
