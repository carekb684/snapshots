import 'package:flutter/material.dart';
import 'package:snap_shots/screens/camera.dart';
import 'package:snap_shots/screens/left_inbox.dart';
import 'package:snap_shots/screens/right_map.dart';
import 'package:snap_shots/screens/top_user.dart';


class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController horizontalController = PageController(initialPage: 1);
  bool horizontalScrolling = true;



  @override
  void initState() {
    super.initState();
    horizontalController.addListener(() {
      if (horizontalController.page == 2.0) {
        setHorizontalScroll(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return PageView(
      onPageChanged: pageChanged,
      physics: horizontalScrolling ? null : NeverScrollableScrollPhysics(),
      controller: horizontalController,
      children: [
        LeftInbox(), CameraPageView(horizScroll: setHorizontalScroll), RightMap(changePage: animateToPage),
      ],
    );
  }

  void pageChanged(int value) {
    if (value == 1 || value == 0) {
      setHorizontalScroll(true);
    }
  }

  void animateToPage(int pageNr) {
    horizontalController.animateToPage(pageNr, duration: Duration(milliseconds: 600), curve: Curves.ease);
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
        TopUser(changePage: animateToPage), // 0
        Camera(changePage: animateToPage), // 1
      ],
    );
  }

  void animateToPage(int pageNr) {
    verticalController.animateToPage(pageNr, duration: Duration(milliseconds: 600), curve: Curves.ease);
  }

  void pageChanged(int value) {
    if (value == 0) {
      horizScroll(false);
    } else if (value == 1) {
      horizScroll(true);
    }
  }
}

