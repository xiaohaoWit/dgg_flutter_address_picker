
import 'package:flutter/material.dart';

const BACKGROUND_COLOR = Colors.white;

const Color Tabbar_COLOR = Color.fromRGBO(16,187,184,1);

const Color ITEM_COLOR = Color.fromRGBO(16,187,184,1);

const TextStyle Title_STYLE = TextStyle(color: Color.fromRGBO(51,51,51,1), fontSize: 18.0);

class PickerTheme{
  const PickerTheme({
    this.backgroundColor: BACKGROUND_COLOR,
    this.tabbarColor: Tabbar_COLOR,
    this.itemStyle:ITEM_COLOR,
    this.titleStyle: Title_STYLE,
  });

  static const PickerTheme Default = const PickerTheme();

  final Color backgroundColor;

  final Color tabbarColor;

  final Color itemStyle;

  final TextStyle titleStyle;
}