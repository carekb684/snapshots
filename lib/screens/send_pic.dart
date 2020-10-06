import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/service/firestore.dart';

class SendPic extends StatefulWidget {
  SendPic({this.imagePath});

  String imagePath;
  File imgFile;

  @override
  _SendPicState createState() => _SendPicState();
}

class _SendPicState extends State<SendPic> {

  String selectedDrink = "";
  ItemScrollController _scrollController = ItemScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, Icon> tempList = {
    "Beer": Icon(Icons.local_drink, size: 40,),
    "Red wine": Icon(Icons.local_drink, size: 40),
    "White wine": Icon(Icons.local_drink, size: 40),
    "White wine2": Icon(Icons.local_drink, size: 40),
    "White wine3": Icon(Icons.local_drink, size: 40),
    "White wine4": Icon(Icons.local_drink, size: 40),
    "White wine5": Icon(Icons.local_drink, size: 40),
    "Whiskey": Icon(Icons.local_drink, size: 40),
    "Cider": Icon(Icons.local_drink, size: 40),
    "Water": Icon(Icons.local_drink, size: 40),
    "P2": Icon(Icons.local_drink, size: 40),
  };

  UserData userData;
  FirestoreService fireServ;
  FirebaseStorage storage;
  Location location = Location();

  Completer<LocationData> currentLocation = Completer();

  @override
  void initState() {
    super.initState();

    getLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    fireServ = Provider.of<FirestoreService>(context);
    storage = Provider.of<FirebaseStorage>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: getImageView(),
        bottomNavigationBar: createBottomBar()
    );
  }


  Widget createBottomBar() {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if(details.primaryVelocity < 0){
          showMenu();
        }
      },
      child: BottomAppBar(
        elevation: 0,
        child: getBottomBarComponents(showMenu, false),
      ),
    );
  }

  Widget getBottomBarComponents(Function burgerPressed, bool menuOpen) {
    return Container(
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: 56.0,
      child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: burgerPressed,
              icon: Icon(Icons.menu),
              color: Colors.black,
            ),

            InkWell(
                onTap: burgerPressed,
                child: Text(selectedDrink == "" ? "Select a drink before sending" : selectedDrink, style: TextStyle(color: Colors.black),)),

            IconButton(
              onPressed: () => onTapSend(menuOpen),
              icon: Icon(Icons.send, color: selectedDrink.isEmpty ? Colors.black26 : Colors.black),
              color: Colors.black,
            )
          ]),
    );
  }

  Widget getImageView() {
    return Stack(
        fit: StackFit.expand,
        children: [

          Image.file(saveImg(), fit:BoxFit.fill,),

          Positioned(
            left: 5, top:5,
            child: SafeArea(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    iconSize: 25,
                    onPressed: () => deleteImageAndClose(false),
                  )
              ),
            ),
          )
        ]
    );
  }

  File saveImg() {
    widget.imgFile = File(widget.imagePath);
    return widget.imgFile;
  }

  void deleteImageAndClose(bool doublePop) {
    widget.imgFile.deleteSync();
    Navigator.pop(context);
    if (doublePop) Navigator.pop(context);
  }

  void showMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder( builder: (context, modalSetState) {

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                child: Container(
                    color: Theme.of(context).primaryColorDark,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: 36,
                      ),
                      Container(
                        height: (56 * 6).toDouble(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment(0, 0),
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Positioned(
                                    top: -36,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                          border: Border.all(
                                              color: Theme.of(context).primaryColorDark, width: 10)),
                                      child: Center(
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: userData.photo == null ? "" : userData.photo,
                                            fit: BoxFit.cover,
                                            height: 36,
                                            width: 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(""),
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 25),
                                child: SizedBox(
                                  height: 100,
                                  child: ScrollablePositionedList.builder(
                                      itemScrollController: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tempList.keys.length,
                                      itemBuilder: (context, index) {
                                        String drinkName = tempList.keys.elementAt(index);
                                        return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: InkWell(
                                            onTap: () {

                                              modalSetState(() {
                                                setState(() {
                                                  selectedDrink = drinkName;
                                                  _scrollController.scrollTo(
                                                      index: index, duration: Duration(milliseconds: 500),
                                                      alignment: 0.365 );
                                                });
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selectedDrink == drinkName ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              width: 100,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(drinkName),
                                                  tempList.values.elementAt(index),
                                                  Text(""),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),


                              Text("asdasd"),
                              Text("asdasd"),
                            ],
                          ),
                      ),



                    ],
                  ),
                ),
              ),
              getBottomBarComponents(() => Navigator.pop(context), true),
            ],
          );
          });
        });
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onTapSend(bool menuOpen) {
    if (selectedDrink.isEmpty) {
      showInSnackBar("Select a drink before sending");
      return;
    }

    //update points
    if (userData.points == null) {
      userData.points = 1;
    } else {
      userData.points = userData.points + 1;
    }
    fireServ.addUserData(userData);

    //upload to storage
    var dateNow = DateTime.now();
    StorageUploadTask uploadTask = storage.ref().child("inbox").child(userData.uid).child(dateNow.toIso8601String()).putFile(widget.imgFile);
    uploadTask.onComplete.then((value) async {
      String url = await value.ref.getDownloadURL();
      var locationData = await currentLocation.future;
      fireServ.uploadInboxUrl(userData.uid, url, dateNow, selectedDrink, locationData);
      deleteImageAndClose(menuOpen);
    });


  }

  void getLocation() async {
    var locationData = await location.getLocation();
    currentLocation.complete(locationData);
  }
}
