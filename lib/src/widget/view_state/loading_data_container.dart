import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';
import '../default_appbar.dart';
import '../default_loading.dart';


class LoadingDataContainer extends StatelessWidget {
  final bool showHeader;
  final String title;

  const LoadingDataContainer({
    Key? key,
    this.showHeader = false,
    this.title = defaultLoadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showHeader
          ? DefaultAppBar()
          : null,
      body: DefaultLoading(title: title),
    );
  }
}
