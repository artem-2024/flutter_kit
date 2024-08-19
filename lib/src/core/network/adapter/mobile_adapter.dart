import 'dart:io';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kit/flutter_kit.dart';

import 'ios/cupertino_adapter.dart';

HttpClientAdapter getAdapter() {
  if(defaultTargetPlatform == TargetPlatform.iOS){
    final config = URLSessionConfiguration.ephemeralSessionConfiguration()
      ..allowsCellularAccess = false
      ..allowsConstrainedNetworkAccess = false
      ..allowsExpensiveNetworkAccess = false;
    return CupertinoAdapter(config);
  }

  return DefaultHttpClientAdapter()
    ..onHttpClientCreate = (client) {
      // 配置代理
      if (httpProxyClientHost.isNotEmpty) {
        client.findProxy = (uri) {
          return 'PROXY $httpProxyClientHost';
        };
      }
      /*
       处理android19+的 DioError [DioErrorType.DEFAULT]: HandshakeException: Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate(handshake.cc:363))
       */
      if (defaultTargetPlatform == TargetPlatform.android) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      }
      return client;
    };
}
