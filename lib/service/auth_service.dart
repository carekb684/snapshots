import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_shots/model/LoggedUser.dart';

class AuthService {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  LoggedUser _userFromFirebase(User user) {
    return user == null ? null : LoggedUser(uid: user.uid);
  }

  Stream<LoggedUser> get onAuthStateChanged {
    return firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  void signOut() async{
    await firebaseAuth.signOut();
  }

}




