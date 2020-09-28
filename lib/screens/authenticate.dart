import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/animations/fade_in.dart';
import 'package:snap_shots/screens/sign_up.dart';
import 'package:snap_shots/service/auth_service.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  AuthService auth;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email;
  String password;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = Provider.of<AuthService>(context);
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
                  child: Center(child: FadeAnimation(1.6,Text("Sign in", style: TextStyle(fontSize: 60),))))
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
                      //validator: ,
                      onSaved: (value) => email = value,
                      onFieldSubmitted: (value) => onLoginTap(),
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
                      onFieldSubmitted: (value) => onLoginTap(),
                      validator: (value) => value.isEmpty ? "Please enter a password" : null,
                      onSaved: (value) => password = value,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
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

          FadeAnimation(2, InkWell(
            onTap: onLoginTap,
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
                child: Center(child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)))
              ),
          ),
          ),

            SizedBox(height: 40),
            FadeAnimation(1.5,
                InkWell(
                    child: Text("Don't have an account? Sign up here", style: TextStyle(color: Theme.of(context).primaryColorDark)),
                    onTap: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SignUp())),
                )),
          ],
        ),
      ),
    );
  }

  void onLoginTap() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    auth.signIn(email, password);
  }
}
