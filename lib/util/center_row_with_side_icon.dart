import 'package:flutter/material.dart';

class CenterRowSideIcon extends StatelessWidget {

  CenterRowSideIcon({this.text, this.icon, this.iconLeftSide});
  Text text;
  Icon icon;
  bool iconLeftSide;

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
            child: icon,
          )
      ),
    ) : Spacer();
  }

  Widget getRightSide() {
    return iconLeftSide ? Spacer() :
    Expanded(
      child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding:  EdgeInsets.only(right: 4),
            child: icon,
          )
      ),
    );
  }
}
