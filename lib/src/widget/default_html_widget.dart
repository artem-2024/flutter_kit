import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_selectable_text/fwfh_selectable_text.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'photo_view_page.dart';

/// 默认的富文本Widget
class DefaultHtmlWidget extends StatelessWidget {
  const DefaultHtmlWidget({
    Key? key,
    required this.content,
    this.needWrapScrollView = true,
  }) : super(key: key);
  final String? content;

  /// 是否需要使用scrollView包裹
  final bool needWrapScrollView;

  @override
  Widget build(BuildContext context) {
    Widget body = HtmlWidget(
      content ?? '',
      factoryBuilder: () => _MyWidgetFactory(),
      onTapUrl: (url) async {
        launchUrlString(url, mode: LaunchMode.externalApplication);
        return true;
      },
      onTapImage: (image) {
        // 图片查看显示
        PhotoViewPage.showPhotoViewDialog(
          context: context,
          urlList: [image.sources.first.url],
        );
      },
      textStyle: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );

    if (needWrapScrollView) {
      body =  SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: body,
      );
    }
    return body;
  }
}

/// 扩展富文本支持项（eg:支持选中）
class _MyWidgetFactory extends WidgetFactory with SelectableTextFactory {}
