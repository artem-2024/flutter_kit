import 'dart:io';

import 'package:flutter/material.dart';

import '../../flutter_kit_core.dart';
import '../utils/logger.dart';
import 'view_state.dart';

export 'view_state.dart';

///
/// ViewModel基类
///
class ViewStateModel with ChangeNotifier {
  /// 防止页面销毁后,异步任务才完成,导致报错
  bool _disposed = false;

  /// 当前的页面状态,默认为busy,可在viewModel的构造方法中指定;
  ViewState _viewState;

  /// 根据状态构造
  ///
  /// 子类可以在构造函数指定需要的页面状态
  /// FooModel():super(viewState:ViewState.busy);
  ViewStateModel({ViewState? viewState})
      : _viewState = viewState ?? ViewState.idle {
    debugPrint('ViewStateModel---constructor--->$runtimeType');
  }

  /// ViewState
  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    if (_viewState == viewState) return;
    _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  /// ViewStateError
  ViewStateError? _viewStateError;

  ViewStateError? get viewStateError => _viewStateError;

  bool get isBusy => viewState == ViewState.busy;

  bool get isIdle => viewState == ViewState.idle;

  bool get isEmpty => viewState == ViewState.empty;

  bool get isError => viewState == ViewState.error;

  /// set
  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  /// 设置认证状态失效
  void setUnAuthError({String? title, String? btnStr}) {
    viewState = ViewState.error;
    _viewStateError = ViewStateError(
      ViewStateErrorType.unauthorizedError,
      message: btnStr,
      errorMessage: title,
    );
  }

  /// [e]分类Error和Exception两种
  /// [e]分类Error和Exception两种
  void setError(e, s, {String? message}) {
    ViewStateErrorType errorType = ViewStateErrorType.defaultError;
    if (message != null && message != '') {
      LogUtils.instance.e('setError = $message');
      s = message;
    } else {
      if (e is DioError) {
        if (e.type == DioErrorType.connectTimeout ||
            e.type == DioErrorType.sendTimeout ||
            e.type == DioErrorType.receiveTimeout) {
          // timeout
          errorType = ViewStateErrorType.networkTimeOutError;
          message = e.error;
        } else if (e.type == DioErrorType.response) {
          // incorrect status, such as 404, 503...
          message = e.error;
        } else if (e.type == DioErrorType.cancel) {
          // to be continue...
          message = e.error;
        } else {
          // dio将原error重新套了一层
          e = e.error;
          if (e is LogicException) {
            if(e.type == LogicExceptionType.tokenExpire){
              s = null;
              errorType = ViewStateErrorType.unauthorizedError;
            }
            message = e.toString();
          } else if (e is HttpException) {
            s = null;
            message = e.message;
          } else if (e is SocketException) {
            errorType = ViewStateErrorType.networkTimeOutError;
            message = e.message;
          } else {
            message = '未知异常';
          }
        }
      }
    }

    /// 见https://github.com/flutterchina/dio/blob/master/README-ZH.md#dioerrortype

    viewState = ViewState.error;
    _viewStateError = ViewStateError(
      errorType,
      message: message,
      errorMessage: e.toString(),
    );
    printErrorStack(e, s);
    onError(viewStateError);
  }

  void onError(ViewStateError? viewStateError) {}

  @override
  String toString() {
    return 'view_state_model{_viewState: $viewState, _viewStateError: $_viewStateError}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    debugPrint('view_state_model dispose -->$runtimeType');
    super.dispose();
  }
}

/// [e]为错误类型 :可能为 Error , Exception ,String
/// [s]为堆栈信息
printErrorStack(e, s) {
  debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->''');
  if (s != null) {
    debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
    ''');
  }
}
