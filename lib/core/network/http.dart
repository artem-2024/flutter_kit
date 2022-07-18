import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';

import '../../flutter_kit.dart';
import '../../utils/devices_info.dart';
import '../../utils/logger.dart';
import '../../utils/package_info.dart';
import 'base_response.dart';

/// http网络请求
class HttpClientDio extends DioForNative {
  /// 单例
  static HttpClientDio get instance => _getInstance();
  static HttpClientDio? _instance;

  static HttpClientDio _getInstance() =>
      _instance ??= HttpClientDio._internal();

  HttpClientDio._internal() {
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
    interceptors.addAll([
      _RequestBeforeInterceptors(),
      _LoggerInterceptors(),
      _ResponseAfterInterceptors(),
    ]);
  }
}

/// 解析json
parseJsonCallback(String text) => compute(_parseAndDecode, text);

_parseAndDecode(String response) => jsonDecode(response);

/// 默认的请求拦截器
class _RequestBeforeInterceptors extends InterceptorsWrapper {
  /// 平台名称
  final platform = defaultTargetPlatform.name;

  /// 版本号code
  String? versionCode;

  /// 版本号名称
  String? versionName;

  /// 设备全部信息
  dynamic extraDeviceInfo;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 获取版本名称
    versionName ??= await PackageInfoUtils.instance.getVersionName();
    // 获取版本号
    versionCode ??= await PackageInfoUtils.instance.getVersionCode();
    // 设备全部信息
    extraDeviceInfo ??= (await DevicesInfoUtils.instance.deviceAllInfo);

    // 公共参数
    final params = {
      'platform': platform,
      'versionName': versionName,
      'versionCode': versionCode,
      'extraDeviceInfo': extraDeviceInfo,
    };

    // 设置公共请求头
    options.headers.addAll(params);

    handler.next(options);
  }
}

/// 默认的响应拦截器
class _ResponseAfterInterceptors extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 暂不拦截流数据的返回
    if (response.requestOptions.responseType == ResponseType.stream) {
      return handler.resolve(response);
    }

    if (response.data is String) response.data = json.decode(response.data);

    final BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    response.data = baseResponse;

    handler.next(response);
  }
}

/// 日志拦截器
class _LoggerInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LogUtils.instance.i("""✅ start request url ${options.uri.toString()}
✅ ==================================================================
✅ url:${options.uri.toString()}
✅ method:${options.method}
✅ header:${options.headers}
✅ queryParameters:${options.queryParameters}
✅ body:${options.data}
✅ ==================================================================""");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LogUtils.instance.i(
        """🇨🇳 server interface response address ${response.requestOptions.uri}
🇨🇳 ==================================================================
🇨🇳 Return Data
🇨🇳 ==================================================================
🇨🇳 ${response.data}
🇨🇳 ==================================================================""");
    handler.next(response);
  }
}
