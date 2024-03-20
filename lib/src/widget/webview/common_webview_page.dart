// import 'package:flutter/material.dart';
//
// import '../../../flutter_kit.dart';
// import '../default_appbar.dart';
// import 'native_webview.dart';
//
// class CommonWebViewPage extends StatefulWidget {
//   final String? url;
//   /// 也可以直接传递html字符串
//   final String? initHtmlStr;
//   /// 标题
//   final String? title;
//
//   const CommonWebViewPage({
//     Key? key,
//     required this.url,
//     this.initHtmlStr,
//     this.title,
//   }) : super(key: key);
//
//   @override
//   CommonWebViewPageState createState() => CommonWebViewPageState();
// }
//
// class CommonWebViewPageState extends State<CommonWebViewPage> {
//   final ValueNotifier<String> _title = ValueNotifier("");
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(defaultAppBarHeight),
//         child: DefaultAppBar(
//           title: ValueListenableBuilder(
//             valueListenable: _title,
//             builder: (BuildContext context, String value, Widget? child) {
//               return DefaultTitleWidget(
//                 titleContent: value,
//               );
//             },
//           ),
//         ),
//       ),
//       body: NativeWebView(
//         url: widget.url,
//         initHtmlStr: widget.initHtmlStr,
//         onTitleCallback: (t) {
//           _title.value = t;
//         },
//       ),
//     );
//   }
// }
