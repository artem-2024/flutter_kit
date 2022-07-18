
/// 管理页面的状态，根据不同的状态显示不同的widget
enum ViewState {
  idle,//正常状态
  busy, //加载中
  empty, //无数据
  error, //加载失败
}

/// 错误类型
enum ViewStateErrorType {
  defaultError,
  networkTimeOutError, //网络错误
  unauthorizedError //为授权(一般为未登录或登录过期)
}

class ViewStateError {
  ViewStateErrorType? _errorType;
  String? message;
  String? errorMessage;

  ViewStateError(this._errorType, {this.message, this.errorMessage}) {
    _errorType ??= ViewStateErrorType.defaultError;
    message ??= errorMessage;
  }

  ViewStateErrorType? get errorType => _errorType;

  bool get isDefaultError => _errorType == ViewStateErrorType.defaultError;
  bool get isNetworkTimeOut => _errorType == ViewStateErrorType.networkTimeOutError;
  bool get isUnauthorized => _errorType == ViewStateErrorType.unauthorizedError;

  @override
  String toString() {
    return 'ViewStateError{errorType: $_errorType, message: $message, errorMessage: $errorMessage}';
  }
}
