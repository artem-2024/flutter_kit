import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'logger.dart';

/// 缓存管理类

class CacheUtil {
  CacheUtil._();

  /// 获取缓存大小 返回总字节数
  static Future<int> total() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      int total = await _reduce(tempDir);
      return total;
    } catch (e, s) {
      LogUtils.instance.e('获取缓存大小出错', e, s);
      return 0;
    }
  }

  /// 清除缓存
  static Future<bool> clear() async {
    try{
      Directory tempDir = await getTemporaryDirectory();
      await _delete(tempDir);
      return true;
    }catch(e,s){
      LogUtils.instance.e('清除缓存出错', e, s);
      return false;
    }

  }

  /// 递归缓存目录，计算缓存大小
  static Future<int> _reduce(final FileSystemEntity file) async {
    /// 如果是一个文件，则直接返回文件大小
    if (file is File) {
      int length = await file.length();
      return length;
    }

    /// 如果是目录，则遍历目录并累计大小
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();

      int total = 0;

      if (children.isNotEmpty)
        for (final FileSystemEntity child in children) {
          total += await _reduce(child);
        }

      return total;
    }

    return 0;
  }

  /// 递归删除缓存目录和文件
  static Future<void> _delete(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delete(child);
      }
    } else {
      await file.delete();
    }
  }
}
