import 'package:flutter/material.dart';

mixin StateAble<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
