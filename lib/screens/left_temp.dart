import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/service/auth_service.dart';

class LeftTemp extends StatefulWidget {

  @override
  _LeftTempState createState() => _LeftTempState();
}

class _LeftTempState extends State<LeftTemp> {


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(
              children: [
                Text("left"),
                SizedBox(height: 40),

              ],
            )));
  }


}
