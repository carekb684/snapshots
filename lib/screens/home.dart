import 'package:flutter/material.dart';
import 'package:snap_shots/screens/camera.dart';
import 'package:snap_shots/screens/left_temp.dart';
import 'package:snap_shots/screens/right_temp.dart';
import 'package:snap_shots/screens/top_temp.dart';


class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController horizontalController = PageController(initialPage: 1);
  bool horizontalScrolling = true;

  @override
  Widget build(BuildContext context) {

    return PageView(
      physics: horizontalScrolling ? null : NeverScrollableScrollPhysics(),
      controller: horizontalController,
      children: [
        LeftTemp(), CameraPageView(horizScroll: setHorizontalScroll), RightTemp(),
      ],
    );
  }


  void setHorizontalScroll(bool enable) {
    setState(() {
      horizontalScrolling = enable;
    });
  }

}

class CameraPageView extends StatelessWidget {
  CameraPageView({this.horizScroll});
  Function horizScroll;

  PageController verticalController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {

    return PageView(
      onPageChanged: pageChanged,
      scrollDirection: Axis.vertical,
      controller: verticalController,
      children: [
        TopTemp(), // 0
        Camera(changePage: animateToPage), // 1
      ],
    );
  }

  void animateToPage(int pageNr) {
    verticalController.animateToPage(pageNr, duration: Duration(milliseconds: 700), curve: Curves.ease);
  }

  void pageChanged(int value) {
    if (value == 0) {
      horizScroll(false);
    } else if (value == 1) {
      horizScroll(true);
    }
  }
}

