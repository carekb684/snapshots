import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snap_shots/model/LoggedUser.dart';


class FirestoreService {

  FirestoreService({@required this.loggedUid});

  final String loggedUid;
  final firestore = FirebaseFirestore.instance;

  void addUser(LoggedUser user) {
    Map obj = <String, dynamic>{"displayname": user.displayName, "uid": user.uid, "username": user.userName, "email": user.email};
    firestore.collection("users").doc(user.uid).set(obj);
  }

}
