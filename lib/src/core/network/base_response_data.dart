
/// 子类需要重写
abstract class BaseResponseData {
  int? code;
  String? message;
  dynamic data;

  bool get success;

  BaseResponseData({this.code = 0, this.message, this.data});

  @override
  String toString() {
    return 'BaseRespData{code: $code, message: $message, data: $data}';
  }
}
