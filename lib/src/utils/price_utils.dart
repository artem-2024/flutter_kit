import 'package:flutter/material.dart';

import '../../flutter_kit.dart';

const _defaultPricePreFix = '¥';
const _defaultFreeStr = '免费';
/// 格式化价格 转换为字符串
String? formatPrice(num? price, {bool doAppendPriceFix = false}) {
  if (price == null || price == 0) return null;
  final intValue = price.toInt();
  String resultPrice;
  if (intValue == price) {
    resultPrice = '$intValue';
  } else {
    resultPrice = '$price';
  }
  if (doAppendPriceFix) {
    resultPrice = appendPriceFix(resultPrice)!;
  }
  return resultPrice;
}

/// 格式化价格字符串 转换为字符串
String? formatPriceStr(String? priceStr, {bool doAppendPriceFix = false}) {
  final priceNum = num.tryParse(priceStr ?? '0');
  var formatPriceStr = formatPrice(priceNum);
  if (doAppendPriceFix) {
    formatPriceStr = appendPriceFix(formatPriceStr);
  }
  return formatPriceStr;
}

/// 添加价格标识
String? appendPriceFix(String? priceStr) {
  if (priceStr?.isNotEmpty != true) return priceStr;
  return '$_defaultPricePreFix$priceStr';
}

/// 默认的价格widget
class DefaultPriceWidget extends StatelessWidget {
  const DefaultPriceWidget({
    Key? key,
    this.sellPrice,
    this.originalPrice,
    this.sellPriceFontSize = 16,
    this.originalPriceFontSize = 14,
    this.prefixText,
    this.shouldFontWeight = true,
    this.originalPricePadding = const EdgeInsets.only(left: 4, bottom: 0),
    this.sellPriceTextColor =  const Color(0xffFF9900),
    this.textBaseline,
    this.crossAxisAlignment =  CrossAxisAlignment.end,
  }) : super(key: key);
  final String? sellPrice;
  final String? originalPrice;
  final double sellPriceFontSize;
  final double originalPriceFontSize;
  final String? prefixText;
  final bool shouldFontWeight;
  final EdgeInsetsGeometry originalPricePadding;
  final Color sellPriceTextColor;
  final TextBaseline? textBaseline;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  Widget build(BuildContext context) {
    Widget child;
    final isFree = num.tryParse(sellPrice ?? '0') == 0;
    if (isFree) {
      child = Text(
        _defaultFreeStr,
        style: TextStyle(
          fontSize: sellPriceFontSize,
          fontWeight: shouldFontWeight ? fontWeight : null,
          color: sellPriceTextColor,
        ),
      );
    }else{
      final showSellPrice = formatPriceStr(sellPrice);
      final showOriginalPrice = formatPriceStr(originalPrice);
      child  = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        textBaseline:textBaseline,
        children: [
          Offstage(
            offstage: prefixText?.isNotEmpty != true,
            child: Text(
              prefixText ?? '',
              style: TextStyle(
                fontSize: sellPriceFontSize,
                fontWeight: shouldFontWeight ? fontWeight : null,
                color: sellPriceTextColor,
              ),
            ),
          ),
          Text(
            _defaultPricePreFix,
            style: TextStyle(
              fontSize: sellPriceFontSize - 4,
              fontWeight: shouldFontWeight ? fontWeight : null,
              color: sellPriceTextColor,
            ),
          ),
          Text(
            showSellPrice ?? '0',
            style: TextStyle(
              fontSize: sellPriceFontSize,
              fontWeight: shouldFontWeight ? fontWeight : null,
              color: sellPriceTextColor,
              height: 1.1
            ),
          ),
          Offstage(
            offstage: showOriginalPrice?.isNotEmpty != true,
            child: Padding(
              padding: originalPricePadding,
              child: Text(
                showOriginalPrice != null ? '$_defaultPricePreFix$showOriginalPrice' : '',
                style: TextStyle(
                  fontSize: originalPriceFontSize,
                  decoration: TextDecoration.lineThrough,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      );
    }
    // 处理iOS audit
    // if (defaultTargetPlatform == TargetPlatform.iOS) {
    //   child = Selector<SaasModel, bool?>(
    //     selector: (_, viewModel) => viewModel.isIOSAuditNow,
    //     builder: (_, isIOSAuditNow, child) {
    //       return Offstage(
    //         offstage: isIOSAuditNow == true,
    //         child: child!,
    //       );
    //     },
    //     child: child,
    //   );
    // }
    return child;
  }
}
