class BaseResponse {
  int? _code;
  String? _message;
  dynamic _data;

  int? get code => _code;

  String? get message => _message;

  dynamic get data => _data;

  BaseResponse({
    int? code,
    String? message,
    dynamic data,
  }) {
    _code = code;
    _message = message;
    _data = data;
  }

  BaseResponse.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["msg"];
    _data = json["data"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    map["data"] = _data;
    return map;
  }
}
