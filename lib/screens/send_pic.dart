import 'dart:io';

import 'package:flutter/material.dart';

class SendPic extends StatefulWidget {
  SendPic({this.imagePath});

  String imagePath;
  File imgFile;

  @override
  _SendPicState createState() => _SendPicState();
}

class _SendPicState extends State<SendPic> {

  String selectedDrink = "";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: getBottomBarComponents(showMenu),
      ),
    );
  }

  Widget getBottomBarComponents(Function burgerPressed) {
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
                child: Text("Select a drink before sending", style: TextStyle(color: Colors.black),)),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.send),
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
                    onPressed: closeImagePressed,
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

  void closeImagePressed() {
    widget.imgFile.deleteSync();
    Navigator.pop(context);
  }

  void showMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder( builder: (context, modalSetState) {

          return ClipRRect(
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
                  SizedBox(
                      height: (56 * 6).toDouble(),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Stack(
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
                                      child: Image.network(
                                        "https://i.stack.imgur.com/S11YG.jpg?s=64&g=1",
                                        fit: BoxFit.cover,
                                        height: 36,
                                        width: 36,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                                  Padding(
                                    padding: EdgeInsets.only(top: 25),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tempList.keys.length,
                                      itemBuilder: (context, index) {
                                        String drinkName = tempList.keys.elementAt(index);
                                        return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: InkWell(
                                            onTap: () {
                                              modalSetState(() {
                                                selectedDrink = drinkName;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selectedDrink == drinkName ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              width: 100,
                                              child: Column(
                                                children: [
                                                  Text(drinkName),
                                                  tempList.values.elementAt(index),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  ),
                            ],
                          ))),

                  getBottomBarComponents(() => Navigator.pop(context)),

                ],
              ),
            ),
          );
          });
        });
  }


}
