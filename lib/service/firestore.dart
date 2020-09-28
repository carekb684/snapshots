import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snap_shots/model/LoggedUser.dart';
import 'package:snap_shots/model/UserData.dart';


class FirestoreService {

  FirestoreService();

  final firestore = FirebaseFirestore.instance;

  Future<void> addUserData(UserData user) {
    Map obj = <String, dynamic>{
      "displayname": user.displayName, "uid": user.uid,
      "username": user.userName, "email": user.email,
      "photo": user.photo,
    };
    return firestore.collection("users").doc(user.uid).set(obj);
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return firestore.collection("users").doc(uid).get();
  }

}
