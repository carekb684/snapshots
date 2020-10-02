import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snap_shots/model/UserData.dart';


class FirestoreService {

  FirestoreService();

  final firestore = FirebaseFirestore.instance;

  Future<void> addUserData(UserData user) {
    Map obj = <String, dynamic>{
      "displayname": user.displayName, "uid": user.uid,
      "username": user.userName, "email": user.email,
      "photo": user.photo, "points": user.points,
    };
    return firestore.collection("users").doc(user.uid).set(obj);
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return firestore.collection("users").doc(uid).get();
  }

  Future<QuerySnapshot> getAllUserByUserName(String username) {
    return firestore.collection("users").where("username", isEqualTo: username).get();
  }

  //request is sent to targets docId
  Future<void> sendFriendRequest(String targetId, String loggedUid) {
    var ref = firestore.collection("friendrequests").doc(targetId);
    ref.set({}, SetOptions(merge:true));

    Map data = <String, dynamic>{"from": loggedUid, "accepted": false,};
    return firestore.collection("friendrequests").doc(targetId).update({"uids" : FieldValue.arrayUnion([data])});
  }

  // no entry == friend request deleted
  // accepted = false not yet accepted
  // accepted = friends
  Future<DocumentSnapshot> getFriendStatus(String targetId) {
    return firestore.collection("friendrequests").doc(targetId).get();
  }

  Future<void> acceptFriendRequest(String myId, String requesterId) {
    //update request
    firestore.collection("friendrequests").doc(myId).update({"uids" : FieldValue.arrayRemove([{"from" : requesterId, "accepted" : false}])});
    firestore.collection("friendrequests").doc(myId).update({"uids" : FieldValue.arrayUnion([{"from" : requesterId, "accepted" : true}])});

    // add to requester list
    var friendRef = firestore.collection("users").doc(requesterId).collection("friendlist").doc(requesterId);
    friendRef.set({}, SetOptions(merge:true));
    firestore.collection("users").doc(requesterId).collection("friendlist").doc(requesterId).update({"uids" : FieldValue.arrayUnion([myId])});

    // add to my list
    var ref = firestore.collection("users").doc(myId).collection("friendlist").doc(myId);
    ref.set({}, SetOptions(merge:true));
    return firestore.collection("users").doc(myId).collection("friendlist").doc(myId).update({"uids" : FieldValue.arrayUnion([requesterId])});
  }

  Future<void> denyFriendRequest(String myId, String requesterId) {
    //update request
    return firestore.collection("friendrequests").doc(myId).update({"uids" : FieldValue.arrayRemove([{"from" : requesterId, "accepted" : false}])});
  }

  Future<DocumentSnapshot> getFriends(String myId) {
    return firestore.collection("users").doc(myId).collection("friendlist").doc(myId).get();

  }

  void uploadInboxUrl(String myId, String url, DateTime dateTime, String drink) {
    var ref = firestore.collection("users").doc(myId).collection("inbox").doc(myId);
    ref.set({}, SetOptions(merge:true));

    Map data = <String, dynamic>{"photo": url, "date": dateTime.toIso8601String(), "drink" : drink};
     firestore.collection("users").doc(myId).collection("inbox").doc(myId).update({"inbox" : FieldValue.arrayUnion([data])});
  }

  Future<DocumentSnapshot> getInbox(String uid) {
    return firestore.collection("users").doc(uid).collection("inbox").doc(uid).get();
  }

}
