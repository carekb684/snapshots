import 'package:flutter/material.dart';
import 'package:snap_shots/screens/camera.dart';
import 'package:snap_shots/screens/left_temp.dart';
import 'package:snap_shots/screens/right_temp.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  PageController controller = PageController(initialPage: 1);
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: [
        LeftTemp(),
        Camera(),
        RightTemp(),
      ],
    );
  }
}
