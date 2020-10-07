import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/animations/fade_in.dart';
import 'package:snap_shots/inherited_widgets/number_of_requests.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/serializer/fire_serialize.dart';
import 'package:snap_shots/service/firestore.dart';
import 'package:snap_shots/util/widget_util.dart';

class ManageFriends extends StatefulWidget {
  @override
  _ManageFriendsState createState() => _ManageFriendsState();
}

class _ManageFriendsState extends State<ManageFriends> {
  UserData userData;
  FirestoreService fireServ;
  NrOfRequests nrOfRequests;

  Future<List<DocumentSnapshot>> fUserRequests;
  List<UserData> userRequests;
  bool requestsRunOnce = true;

  Future<List<DocumentSnapshot>> fUserFriends;
  List<UserData> userFriends;
  bool friendsRunOnce = true;




  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    fireServ = Provider.of<FirestoreService>(context);
    nrOfRequests = Provider.of<NrOfRequests>(context);

    getFriendRequests();
    getFriends();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),

              FutureBuilder<List<DocumentSnapshot>>(
                future: fUserRequests,
                builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.hasData && snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data.isEmpty) {
                      return Container();
                    }

                    return getRequestsList(snapshot.data);

                  } else if (fUserRequests != null){
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Container();
                  }
                },
              ),

              FutureBuilder<List<DocumentSnapshot>>(
                future: fUserFriends,
                builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.hasData && snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data.isEmpty) {
                      return Container();
                    }

                    return getFriendsList(snapshot.data);

                  } else if (fUserFriends != null){
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Container();
                  }
                },
              ),


            ],
          )
        )
      )
    );
  }

  void getFriendRequests() {
    fireServ.getFriendStatus(userData.uid).then((value) {
      if (value.data() != null) {

        List<String> requests = [];
        var maps = value.data()["uids"];
        for(dynamic map in maps) {
          if(map["accepted"] == false) requests.add(map["from"]);
        }

        List<Future<DocumentSnapshot>> fUserDatas = [];
        for (String uid in requests) {
          fUserDatas.add(fireServ.getUser(uid));
        }

        setState(() {
          fUserRequests = Future.wait(fUserDatas);
        });

      }
    });
  }

  Widget getRequestsList(List<DocumentSnapshot> data) {
    if (requestsRunOnce) {
      userRequests = data.map((e) => FireSerialize.toUserData(e.data())).toList();
      requestsRunOnce = false;
    }

    if (userRequests.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [

          SizedBox(height: 5),
          Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Friend requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          SizedBox(height: 10,),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: userRequests.length,
            separatorBuilder: (context, index) => Divider(height: 0, thickness: 0.5,),
            itemBuilder: (context, index) {
              UserData user = userRequests[index];

              return FadeAnimation( 0.4 + (index * 0.1),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: WidgetUtil.getBorderRadius(index, userRequests.length),
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
                      trailing: getRequestTrailing(index),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 10),
      ],),
    );

  }

  Widget getRequestTrailing(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        getAcceptDenyBox(
          iButton: IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: (){
              onAcceptRequest(index);
            },
          ),
        ),
        SizedBox(width: 10),
        getAcceptDenyBox(
          iButton: IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: (){
              onDenyRequest(index);
            },
          ),
        ),
      ],
    );
  }

  Widget getAcceptDenyBox({IconButton iButton}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            offset: Offset(0, 5))],
        borderRadius: BorderRadius.circular(10),
      ),
      child: iButton,
    );
  }

  void onAcceptRequest(int index) {
    fireServ.acceptFriendRequest(userData.uid, userRequests[index].uid).then((value) {

      nrOfRequests.decrement();
      //Todo: Maybe i can just add friend offline to local list instead of retrieving?
      //getFriends() will run setState()
      friendsRunOnce = true;
      userRequests.removeAt(index);
      getFriends();
    });
  }

  void onDenyRequest(int index) {
    fireServ.denyFriendRequest(userData.uid, userRequests[index].uid).then((value)  {
      nrOfRequests.decrement();

      setState(() {
        userRequests.removeAt(index);
      });
    });
  }

  void getFriends() {
    fireServ.getFriends(userData.uid).then((value) {

      if (value.data() != null) {

        List<Future<DocumentSnapshot>> fUserDatas = [];
        var list = value.data()["uids"];
        for (String uid in list) {
          fUserDatas.add(fireServ.getUser(uid));
        }

        setState(() {
          friendsRunOnce = true;
          fUserFriends = Future.wait(fUserDatas);
        });
      }
    });
  }

  Widget getFriendsList(List<DocumentSnapshot> data) {
    if (friendsRunOnce) {
      userFriends = data.map((e) => FireSerialize.toUserData(e.data())).toList();
      friendsRunOnce = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [

          SizedBox(height: 5),
          Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Friends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          SizedBox(height: 10,),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: userFriends.length,
            separatorBuilder: (context, index) => Divider(height: 0, thickness: 0.5,),
            itemBuilder: (context, index) {
              UserData user = userFriends[index];

              return FadeAnimation(0.4 + (index * 0.1),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: WidgetUtil.getBorderRadius(index, userFriends.length),
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
                  ),
                ),
              );
            },
          ),

        ],),
    );
  }

}
