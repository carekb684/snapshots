import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_shots/model/LoggedUser.dart';
import 'package:snap_shots/model/UserData.dart';

class FireSerialize {


  static LoggedUser userFromFirebase(User user) {
    return user == null ? null : LoggedUser(uid: user.uid, email: user.email, displayName: user.displayName);
  }

  static UserData toUserData(Map<String, dynamic> map) {
    return UserData(displayName: map["displayname"], email: map["email"], userName: map["username"], photo: map["photo"], uid: map["uid"]);
  }
}