
class StringUtil {
  StringUtil._();

  /// 格式化数字小数
  /// position 小数点后几位
  static String formatNum(num num, int position) {
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) <
        position) {
      //小数点后有几位小数
      return num.toStringAsFixed(position)
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    } else {
      return num.toString()
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    }
  }

  /// 转文字为html，支持链接和网络图片,[replaceImageUrlFunc]：可自定义图片转换
  static String replaceToHtml(String? text,
      {String Function(String imageUrl)? replaceImageUrlFunc}) {
    if (text?.isNotEmpty != true) return '';
    // url正则
    // 可选 r'^(.*?)((?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*)'
    // 可选简单的判断 r'^(.*?)((https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*))',
    final urlRegex = RegExp(
      r'(https?|ftp|file):\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]',
      caseSensitive: false, // 忽略大小写
      dotAll: true,
    );
    // 支持的图片后缀正则
    final imageSuffixRegex =
        RegExp(r'(jpe?g|png|bmp|gif)', caseSensitive: false);

    // 匹配替换
    text = text!.replaceAllMapped(urlRegex, (match) {
      final matchUrl = match.group(0);
      if ((matchUrl?.indexOf(imageSuffixRegex) ?? -1) > 0) {
        if (replaceImageUrlFunc != null) {
          return replaceImageUrlFunc.call(matchUrl!);
        }
        return '<img src="$matchUrl" style="max-width:100%;height:auto;" />';
      }
      return '<a href="$matchUrl">$matchUrl</a>';
    });
    return text;
  }

  /// 对bytes进行转换
  static String? formatBytes(int? bytes,
      {String bStr = 'B', String kStr = 'K', String mStr = 'M', String gStr = 'G', int toStringAsFixed = 1,}) {
    if (bytes == null) return null;
    if (bytes < 1024) {
      return '$bytes$bStr';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(toStringAsFixed)}$kStr';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(toStringAsFixed)}$mStr';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(toStringAsFixed)}$gStr';
    }
  }
}
