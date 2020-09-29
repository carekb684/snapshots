import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:snap_shots/model/UserData.dart';

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

  @override
  void didChangeDependencies() {
    userData = Provider.of<UserData>(context);
    super.didChangeDependencies();
  }

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
                child: Text(selectedDrink == "" ? "Select a drink before sending" : selectedDrink, style: TextStyle(color: Colors.black),)),

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
                                          child: Image.network(
                                            userData.photo == null ? "" : userData.photo,
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
              getBottomBarComponents(() => Navigator.pop(context)),
            ],
          );
          });
        });
  }


}
