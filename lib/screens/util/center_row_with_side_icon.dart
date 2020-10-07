import 'package:flutter/material.dart';
import 'dart:math' as math;

class CenterRowSideIcon extends StatelessWidget {

  CenterRowSideIcon({this.text, this.icon, this.iconLeftSide, this.mirrorIcon = false});
  Widget text;
  Widget icon;
  bool iconLeftSide;
  bool mirrorIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getLeftSide(),
        text,
        getRightSide(),
      ],
    );
  }


  Widget getLeftSide() {
    return iconLeftSide ?
    Expanded(
      child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding:  EdgeInsets.only(right: 4),
            child: getIcon(),
          )
      ),
    ) : Spacer();
  }

  Widget getRightSide() {
    return iconLeftSide ? Spacer() :
    Expanded(
      child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding:  EdgeInsets.only(left: 4),
            child: getIcon(),
          )
      ),
    );
  }

  Widget getIcon() {

    if( mirrorIcon) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: icon,
      );
    }
    return icon;
  }
}
