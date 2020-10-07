import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/serializer/fire_serialize.dart';
import 'package:snap_shots/service/firestore.dart';

class AddFriends extends StatefulWidget {
  @override
  _AddFriendsState createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {

  FocusNode searchFocus;

  FirestoreService fireServ;
  Future<QuerySnapshot> futureUsers;

  UserData userData;

  Widget trailingIcon;

  bool runOnce = true;

  Map<String, Widget> trailingIcons = {};

  List<UserData> resultList = [];

  @override
  void initState() {
    super.initState();

    searchFocus = FocusNode();
    searchFocus.requestFocus();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible) searchFocus.unfocus(); //if keyboard dismiss remove focus from textField
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fireServ = Provider.of<FirestoreService>(context);
    userData = Provider.of<UserData>(context);
  }

  @override
  void dispose() {
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(children: [

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(vertical: 3),
              margin: EdgeInsets.symmetric(horizontal: 40),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
              child: TextField(
                focusNode: searchFocus,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    hintText: "Search for username"),
                onSubmitted: onSubmitSearch,
              ),
            ),

            SizedBox(height: 20),

            FutureBuilder<QuerySnapshot>(
              future: futureUsers,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data.docs.isEmpty) {
                    return Text(
                      "No users found :(",
                      style: TextStyle(color: Colors.black),
                    );
                  }

                  return getUserResultList(snapshot.data.docs);

                } else if (futureUsers != null){
                  return CircularProgressIndicator();
                } else {
                  return Container();
                }
              },
            ),

          ]),
        ));
  }

  void onSubmitSearch(String value) {
    setState(() {
      runOnce = true;
      futureUsers = fireServ.getAllUserByUserName(value);
    });
  }

  Widget getUserResultList(List<QueryDocumentSnapshot> docs) {
    if (runOnce) {
      resultList = docs.map((e) => FireSerialize.toUserData(e.data())).toList();
      populateTrailings(resultList);
    }

    return Expanded(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          itemCount: resultList.length,
          itemBuilder: (context, index) {
            UserData user = resultList[index];

            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: ListTile(
                  title: Text(user.displayName),
                  subtitle: Text(user.userName),
                  leading: Container(
                    margin: EdgeInsets.only(top:2.0, bottom: 2.0),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        width: 50,
                        height: 50,
                        imageUrl: user.photo ?? "",
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  trailing: getTrailingWidget(user.uid)
              ),
            );
          },
        ),
      ),
    );

  }

  void onAddFriend(String targetId) {
    fireServ.sendFriendRequest(targetId, userData.uid).then((value) {
      setState(() {
        runOnce = true;
      });
    });
  }

  Widget getTrailingWidget(String targetId) {

    if (runOnce) {
      var myRequest = fireServ.getFriendStatus(targetId); //have i sent a request?
      var targetsRequest = fireServ.getFriendStatus(userData.uid); // have someone sent me a request?

      Future.wait([myRequest, targetsRequest]).then((value) {
        Map<String, dynamic> myReq = value[0].data();
        Map<String, dynamic> targetReq = value[1].data();

        // "have i sent a request ?"
        if (myReq != null) {
          List<dynamic> maps = myReq["uids"];
          for (dynamic map in maps) {
            if (map["from"] == userData.uid) {
              bool friends = map["accepted"];
              setState(() {
                trailingIcons[targetId] = friends ? Icon(Icons.check, color: Colors.green) : Icon(Icons.add, color: Colors.red);
              });
              return;
            }
          }
        }
        //has target sent a request?
        if (targetReq != null) {
          List<dynamic> maps = targetReq["uids"];
          for (dynamic map in maps) {
            if (map["from"] == targetId) {
              bool friends = map["accepted"];
              setState(() {
                trailingIcons[targetId] = friends ? Icon(Icons.check, color: Colors.green) : Icon(Icons.device_unknown, color: Colors.blue);
              });
              return;
            }
          }
        }

        // no requests sent
        setState(() {
          trailingIcons[targetId] =
              IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.add, color: Colors.black12), iconSize: 30, onPressed: () => onAddFriend(targetId),);
        });
      });

      runOnce = false;
    }

    return trailingIcons[targetId];
  }

  void populateTrailings(List<UserData> resultList) {
    for(UserData data in resultList) {
      trailingIcons[data.uid] = CircularProgressIndicator();
    }
  }

}
