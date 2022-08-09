export 'adapter/unsupported.dart'
if (dart.library.html) 'adapter/web_adapter.dart'
if (dart.library.io) 'adapter/mobile_adapter.dart';
