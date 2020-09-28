
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/animations/fade_in.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/service/auth_service.dart';
import 'package:snap_shots/service/firestore.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  AuthService auth;
  FirestoreService fireServ;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email;
  String password;
  String displayName;
  String userName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = Provider.of<AuthService>(context);
    fireServ = Provider.of<FirestoreService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(1),
                          Theme.of(context).primaryColor.withOpacity(0.4),
                        ]
                    ),

                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),)
                ),
                height: 300,
                width: double.infinity,
                child: SafeArea(
                    child: Center(child: FadeAnimation(1.6,Text("Sign up", style: TextStyle(fontSize: 60),))))
            ),

            SizedBox(height:40),

            FadeAnimation(1.8,Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 20.0,
                        offset: Offset(0, 10)
                    )
                  ]
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 20),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[100]))
                      ),
                      child: TextFormField(
                        //validator: (value) =>,
                        onSaved: (newValue) => email = newValue,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey[400])
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 20),
                      child: TextFormField(
                        obscureText: true,
                        validator: (value) => value.length < 6 ? "Password must be at least 6 characters" : null,
                        onSaved: (newValue) => password = newValue,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey[400])
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 20),
                      child: TextFormField(
                        validator: (value) => value.length < 4 ? "Please enter at least 4 characters" : null,
                        onSaved: (newValue) => userName = newValue,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Username",
                            hintStyle: TextStyle(color: Colors.grey[400])
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 20),
                      child: TextFormField(
                        validator: (value) => value.isEmpty ? "Please enter at least 1 character" : null,
                        onSaved: (newValue) => displayName = newValue,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Displayname",
                            hintStyle: TextStyle(color: Colors.grey[400])
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            ),

            SizedBox(height: 30,),

            FadeAnimation(2,
              InkWell(
                  onTap: clickSignUp,
                  child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(1),
                          Theme.of(context).primaryColor.withOpacity(0.6),
                        ]
                    )
                ),
                child: Center(child: Text("Sign up", style: TextStyle(fontWeight: FontWeight.bold))))
            ),
            ),

            SizedBox(height: 40),
            FadeAnimation(1.5,
                InkWell(
                  child: Text("Already have an account? Sign in here", style: TextStyle(color: Theme.of(context).primaryColorDark)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      )
    );
  }

  void signUp(String email, String password, String displayname, String username) {
    auth.signUp(email, password).then((value) {

      fireServ.addUserData(UserData(uid: value.user.uid, displayName: displayname, email: email, photo: null, userName: username));
    });

  }

  void clickSignUp() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    signUp(email, password, displayName, userName);
  }
}
