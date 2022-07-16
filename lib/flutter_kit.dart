
import 'flutter_kit_platform_interface.dart';

class FlutterKit {
  Future<String?> getPlatformVersion() {
    return FlutterKitPlatform.instance.getPlatformVersion();
  }
}
