import 'package:flutter/material.dart';

class WidgetUtil {

  static BorderRadius getBorderRadius(int index, int length) {
    double top = 0;
    double bottom = 0;

    if(index == 0) top = 20;
    if (index == length -1) bottom = 20;

    return BorderRadius.vertical(top: Radius.circular(top), bottom:  Radius.circular(bottom));
  }

}