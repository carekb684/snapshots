import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_shots/model/LoggedUser.dart';
import 'package:snap_shots/serializer/fire_serialize.dart';

class AuthService {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  Stream<LoggedUser> get onAuthStateChanged {
    return firebaseAuth.authStateChanges().map(FireSerialize.userFromFirebase);
  }

  void signOut() async{
    await firebaseAuth.signOut();
  }

  Future<UserCredential> signUp(String email, String password) {
    return firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  void signIn(String email, String password) {
    firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

}




