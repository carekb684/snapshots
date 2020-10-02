import 'package:flutter/cupertino.dart';

class NrOfRequests extends InheritedWidget {


  static NrOfRequests of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }





  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    throw UnimplementedError();
  }

}