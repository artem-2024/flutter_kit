import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';
import 'http_client_adapter_shared.dart';

/// http网络请求抽象类
abstract class BaseHttpClientDio extends DioForNative {
  BaseHttpClientDio() {
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJsonCallback;
    options = BaseOptions(
      connectTimeout: 10 * 1000,
      // 下载需要的时间要长些
      receiveTimeout: 60 * 1000 * 30,
      sendTimeout: 60 * 1000,
    );
    httpClientAdapter = getAdapter();
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
