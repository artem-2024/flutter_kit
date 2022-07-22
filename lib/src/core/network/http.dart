import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';

import '../../../flutter_kit.dart';

/// http网络请求抽象类
abstract class BaseHttpClientDio extends DioForNative {
  BaseHttpClientDio() {
    (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
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
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJsonCallback;
    options = BaseOptions(
      connectTimeout: 60 * 1000,
      // 下载需要的时间要长些
      receiveTimeout: 60 * 1000 * 30,
      sendTimeout: 60 * 1000,
    );
    init();
  }

  void init();
}

/// 解析json
parseJsonCallback(String text) => compute(_parseAndDecode, text);

_parseAndDecode(String response) => jsonDecode(response);


// /// 默认的响应拦截器
// class _ResponseAfterInterceptors extends InterceptorsWrapper {
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     // 暂不拦截流数据的返回
//     if (response.requestOptions.responseType == ResponseType.stream) {
//       return handler.resolve(response);
//     }
//
//     if (response.data is String) response.data = json.decode(response.data);
//
//     final BaseResponse baseResponse = BaseResponse.fromJson(response.data);
//
//     response.data = baseResponse;
//
//     handler.next(response);
//   }
// }


