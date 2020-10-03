import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/animations/fade_in.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/model/inbox_model.dart';
import 'package:snap_shots/model/inbox_user_data.dart';
import 'package:snap_shots/screens/view_story.dart';
import 'package:snap_shots/serializer/fire_serialize.dart';
import 'package:snap_shots/service/auth_service.dart';
import 'package:snap_shots/service/firestore.dart';
import 'package:snap_shots/util/widget_util.dart';

class LeftInbox extends StatefulWidget {
  @override
  _LeftInboxState createState() => _LeftInboxState();
}

class _LeftInboxState extends State<LeftInbox> {
  FirestoreService fireServ;
  UserData userData;

  List<UserData> userDatas = [];
  Future<List<DocumentSnapshot>> fFriendInboxes;
  List<InboxUserData> friendInboxes = [];

  bool runOnce = true;



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    fireServ = Provider.of<FirestoreService>(context);
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
                SizedBox(height: 20),

                FutureBuilder<List<DocumentSnapshot>>(
                  future: fFriendInboxes,
                  builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.hasData && snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data.isEmpty) {
                        return Text(
                          "No users found :(",
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      return getInboxList(snapshot.data);

                    } else if (fFriendInboxes != null){
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Container();
                    }
                  },
                ),


             ],
    ),
          ),
        ));
  }


  void getFriends() {
    fireServ.getFriends(userData.uid).then((value) {

      if (value.data() != null) {

        List<Future<DocumentSnapshot>> fUserDatas = [];
        var list = value.data()["uids"];
        for (String uid in list) {
          fUserDatas.add(fireServ.getUser(uid));
        }


        Future.wait(fUserDatas).then((value) {
          userDatas = value.map((e) => FireSerialize.toUserData(e.data())).toList();

          List<Future<DocumentSnapshot>> fInboxes = [];
          for (UserData data in userDatas) {
            fInboxes.add(fireServ.getInbox(data.uid));
          }

          setState(() {
            fFriendInboxes = Future.wait(fInboxes);
          });

        });

      }
    });
  }

  Widget getInboxList(List<DocumentSnapshot> data) {

    if (runOnce) {
      for (DocumentSnapshot doc in data) {
        if (doc.data() == null) continue;

        var inboxList = doc.data()["inbox"];
        String uid = doc.id;
        List<InboxEntry> userPhotos = [];
        for (dynamic map in inboxList) {
          String date = map["date"];
          String url = map["photo"];
          String drink = map["drink"];
          userPhotos.add(InboxEntry(date: DateTime.parse(date), photo: url, drink: drink));
        }

        var inboxUserData = InboxUserData(inboxEntrys: userPhotos, userData: userDatas.firstWhere((element) => element.uid == uid));
        friendInboxes.add(inboxUserData);
      }
      runOnce = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [

          SizedBox(height: 10,),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: friendInboxes.length,
            separatorBuilder: (context, index) => Divider(height: 0, thickness: 0.5,),
            itemBuilder: (context, index) {
              InboxUserData user = friendInboxes[index];

              return FadeAnimation(0.4 + (index * 0.1),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: WidgetUtil.getBorderRadius(index, friendInboxes.length),
                  ),
                  child: ListTile(
                    title: Text(user.userData.displayName),
                    subtitle: Text(user.userData.userName),
                    leading: Container(
                      margin: EdgeInsets.only(top:2.0, bottom: 2.0),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          width: 50,
                          height: 50,
                          imageUrl: user.userData.photo,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    onTap: () => onTapStory(index),
                    trailing: getTrailing(user.inboxEntrys),
                  ),
                ),
              );
            },
          ),

        ],),
    );
  }

  void onTapStory(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ViewStories(users: friendInboxes, startIndex: index)));
  }

  Widget getTrailing(List<InboxEntry> inboxEntrys) {
    int length = inboxEntrys.length;

    String plusDrinks = length > 1 ? " + " + (length - 1).toString() : "";

    return Text("Drinking " + inboxEntrys.last.drink + plusDrinks);

  }

}
