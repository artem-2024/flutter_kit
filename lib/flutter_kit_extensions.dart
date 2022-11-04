import 'package:flutter/material.dart';

extension BreakpointUtils on BoxConstraints {
  bool get isTablet => maxWidth > 730;
  bool get isDesktop => maxWidth > 1200;
  bool get isMobile => !isTablet && !isDesktop;
}

extension HumanizedDuration on Duration {
  String get toHumanizedString {
    final seconds = '${inSeconds % 60}'.padLeft(2, '0');
    String minutes = '${inMinutes % 60}';
    if (inHours > 0 || inMinutes == 0) {
      minutes = minutes.padLeft(2, '0');
    }
    String value = '$minutes:$seconds';
    if (inHours > 0) {
      value = '$inHours:$minutes:$seconds';
    }
    return value;
  }
}


extension Responsive on BuildContext {
  /// mobile = [defaultVal]   tablet = [md]  desktop = [lg]
  /*
    eg： GridView.count(
    crossAxisCount: context.responsive<int>(
      2, // default
      sm: 2, // small
      md: 3, // medium
      lg: 4, // large
      xl: 5, // extra large screen
    ),
   */
  T responsive<T>(
      T defaultVal, {
        T? sm,
        T? md,
        T? lg,
        T? xl,
      }) {
    final wd = MediaQuery.of(this).size.width;
    return wd >= 1280
        ? (xl ?? lg ?? md ?? sm ?? defaultVal)
        : wd >= 1024
        ? (lg ?? md ?? sm ?? defaultVal)
        : wd >= 768
        ? (md ?? sm ?? defaultVal)
        : wd >= 640
        ? (sm ?? defaultVal)
        : defaultVal;
  }
}