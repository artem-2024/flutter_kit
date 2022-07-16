import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lms_app/config/build_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef OnTitleCallback = Function(String title);

class NativeWebView extends StatefulWidget {
  /// 请求的网址
  final String? url;
  /// 也可以直接传递html字符串
  final String? initHtmlStr;

  /// 拦截页面url
  final NavigationDelegate? navigationDelegate;

  /// 拦截页面url
  final OnTitleCallback? onTitleCallback;

  const NativeWebView({
    Key? key,
    this.url,
    this.navigationDelegate,
    this.onTitleCallback,
    this.initHtmlStr,
  }) : super(key: key);

  @override
  _NativeWebViewState createState() => _NativeWebViewState();
}

class _NativeWebViewState extends State<NativeWebView> {
  /// 进度条
  final ValueNotifier<double> _progress = ValueNotifier<double>(-1);

  late WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 页面正在开始加载
  void _onPageStarted(String url) {}

  /// 页面加载完毕
  void _onPageFinished(String url) async {
    String? title = await _webViewController!.getTitle();
    if (title != null && title.isNotEmpty) {
      widget.onTitleCallback?.call(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _progress,
          builder: (BuildContext context, double value, Widget? child) {
            if (value < 0 || value == 1) {
              return const SizedBox.shrink();
            }
            return LinearProgressIndicator(
              value: value,
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorHelper.colorTextTheme,
              ),
            );
          },
        ),
        Expanded(
          child: WebView(
            onWebViewCreated: (controller) {
              _webViewController = controller;
              if(widget.initHtmlStr?.isNotEmpty == true){
                _webViewController?.loadHtmlString(widget.initHtmlStr!);
              }
            },
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: _onPageStarted,
            onPageFinished: _onPageFinished,
            onProgress: (int progress) {
              _progress.value = progress / 100;
            },
            navigationDelegate: widget.navigationDelegate,
          ),
        ),
      ],
    );
  }
}
