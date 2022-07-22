
import 'package:dio/dio.dart';
import 'package:flutter_kit/src/utils/logger.dart';

/// 日志拦截器
class DefaultLoggerInterceptors extends InterceptorsWrapper {
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
