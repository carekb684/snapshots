import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/authentication/auth_widget_builder.dart';
import 'package:snap_shots/authentication/auth_wrapper.dart';
import 'package:snap_shots/screens/home.dart';
import 'package:snap_shots/service/auth_service.dart';
import 'package:snap_shots/service/firestore.dart';
import 'package:snap_shots/util/color_from_hex.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  FirebaseStorage storage = FirebaseStorage(
      app: app, storageBucket: 'gs://snapshots-46f41.appspot.com');

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  MyApp({this.storage});
  FirebaseStorage storage;

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
        providers: [
          Provider<FirestoreService>(
            create: (_) => FirestoreService(),
          ),
          Provider<AuthService>(
            create: (_) => AuthService(),
          ),
          Provider<FirebaseStorage>(
            create: (_) => storage,
          ),
        ],
      child: AuthWidgetBuilder( builder: (context, snapshot) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthenticationWrapper(userSnapshot: snapshot,),
            //initialRoute: "/auth",
            routes: {
              //"/profile": (context) => MyProfile(),
              //"/leaderboard": (context) => Leaderboard(),
              //"/findfriends": (context) => FindFriends(),
              "/auth": (context) => AuthenticationWrapper(userSnapshot: snapshot),
              "/home": (context) => Home(),
            },
          theme: ThemeData(
            accentColor: HexColor.fromHex("#ffff72"),
            primaryColor: HexColor.fromHex("#ffeb3b"), // usage color: Theme.of(context).
            primaryColorDark: HexColor.fromHex("#c8b900"),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
        );
      }),
    );
  }
}
