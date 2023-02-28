///
/// 业务异常类别
///
enum LogicExceptionType {
  /// token失效
  tokenExpire,

  /// 用户未注册
  userUnRegister,

  /// App需要升级
  appNeedUp,

  /// 其他错误
  other,
}

///
/// 业务异常
///
class LogicException implements Exception {
  int? code;
  LogicExceptionType type;
  String? message;
  bool?needShowErrMsg;

  LogicException(
      this.code, {
        this.message,
        this.type = LogicExceptionType.other,
        this.needShowErrMsg,
      });

  @override
  String toString() {
    return '$message($code)';
  }
}
