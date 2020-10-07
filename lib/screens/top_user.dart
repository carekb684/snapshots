import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/inherited_widgets/number_of_requests.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/screens/add_friends.dart';
import 'package:snap_shots/screens/manage_friends.dart';
import 'package:snap_shots/screens/util/center_row_with_side_icon.dart';
import 'package:snap_shots/service/auth_service.dart';
import 'package:snap_shots/service/firestore.dart';

class TopUser extends StatefulWidget {
  TopUser({this.changePage});
  Function changePage;

  @override
  _TopUserState createState() => _TopUserState();
}

class _TopUserState extends State<TopUser> {
  UserData userData;
  TextEditingController displayNameController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File image;
  final picker = ImagePicker();

  FirebaseStorage storage;
  FirestoreService fireServ;
  AuthService auth;
  NrOfRequests nrOfRequests;

  @override
  void initState() {
    super.initState();

    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible && context != null) FocusScope.of(context).unfocus(); //if keyboard dismiss remove focus from textField
    });
    }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    nrOfRequests = Provider.of<NrOfRequests>(context);
    displayNameController =  new TextEditingController(text: userData.displayName);

    storage = Provider.of<FirebaseStorage>(context);
    fireServ = Provider.of<FirestoreService>(context);
    auth = Provider.of<AuthService>(context);

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onBackButtonPress,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: Container(
          color: Theme.of(context).primaryColor, //unsafe area color
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        height: 360,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [



                            Align(
                              alignment: AlignmentDirectional.topStart,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                iconSize: 30,
                                onPressed: closeImagePressed,
                              ),
                            ),

                            SizedBox(height: 20,),
                            CenterRowSideIcon(
                              icon: Icon(Icons.local_drink),
                              iconLeftSide: false,
                              text: Text(userData.points == null ? "0" : userData.points.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 10,),

                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(200 / 2)),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 6.0,
                                ),
                              ),
                              child: ClipOval(
                                child: InkWell(
                                  onTap: onClickUser,
                                  child: CachedNetworkImage(
                                    imageUrl: userData.photo == null ? "" : userData.photo,
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/avatar.png"), fit: BoxFit.fill)),),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10,),

                            TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(border: InputBorder.none),
                                style: TextStyle(fontWeight: FontWeight.bold),
                                controller: displayNameController,
                                onSubmitted: onSubmitDisplayName,
                              ),

                          ],
                        ),
                    ),
                    SizedBox(height: 20),

                    InkWell(
                      onTap: () => Navigator.push(context,  MaterialPageRoute(builder: (BuildContext context) => AddFriends())),
                      child: CenterRowSideIcon(
                        text: Text("Add friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        icon: Icon(Icons.person_add, size: 30,),
                        iconLeftSide: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () => Navigator.push(context,  MaterialPageRoute(builder: (BuildContext context) => ManageFriends())),
                      child: CenterRowSideIcon(
                        text: Text("Manage friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        icon: nrOfRequests?.getFriendReqIcon(Icon(Icons.supervised_user_circle, size: 30,),),
                        iconLeftSide: true,
                      ),
                    ),

                    SizedBox(height: 40),
                    InkWell(
                      onTap: signOut,
                      child: CenterRowSideIcon(
                          text: Text("Sign out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          icon: Icon(Icons.exit_to_app, size: 30),
                          iconLeftSide: true,
                      ),
                    )

                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );

  }

  void signOut() {
    auth.signOut();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }

  }

  void onClickUser() async{
    await getImage();

    if(image != null) {
      StorageUploadTask uploadTask = storage.ref().child("images").child(userData.uid).putFile(image);
      uploadTask.onComplete.then((value) async {
        String url = await value.ref.getDownloadURL();
        userData.photo = url;
        fireServ.addUserData(userData).then((value){ setState(() {});});
      });

    }
  }

  void closeImagePressed() {
    widget.changePage(1);
  }

  void onSubmitDisplayName(String value) {
    if (value.isEmpty) {
      showInSnackBar("Please enter at least 1 character");
      displayNameController.text = userData.displayName;
    } else {
      userData.displayName = value;
      fireServ.addUserData(userData);
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message), ));
  }

  Future<bool> onBackButtonPress() {
    widget.changePage(1);
    return Future.value(false);
  }

}
