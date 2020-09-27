import 'package:flutter/material.dart';
import 'package:snap_shots/model/LoggedUser.dart';
import 'package:snap_shots/screens/authenticate.dart';
import 'package:snap_shots/screens/home.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key key, @required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<LoggedUser> userSnapshot;

  @override
  Widget build(BuildContext context) {

    return Home();
    /*
    if (userSnapshot.connectionState == ConnectionState.active) {
      return userSnapshot.hasData ? Home() : Authenticate();
    }
     */
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
