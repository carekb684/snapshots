import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:http/http.dart' as http;
import 'package:snap_shots/model/inbox_model.dart';
import 'package:snap_shots/model/inbox_user_data.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:snap_shots/serializer/fire_serialize.dart';
import 'package:snap_shots/service/firestore.dart';
import 'package:snap_shots/util/cache_util.dart';
import 'package:thumbnailer/thumbnailer.dart';

class RightMap extends StatefulWidget {
  RightMap({this.changePage});
  Function changePage;

  /*
   CameraPosition initLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );*/

  @override
  _RightMapState createState() => _RightMapState();
}

class _RightMapState extends State<RightMap> {
  Completer<GoogleMapController> _controller = Completer();

  LocationData currentLocation;
  Location location = Location();

  FirestoreService fireServ;
  UserData userData;
  Set<Marker> _markers = Set<Marker>();

  List<UserData> friendsData = [];
  Future<List<DocumentSnapshot>> fFriendInboxes;

  List<InboxUserData> friendInboxes = [];


  @override
  void initState() {
    super.initState();
    setInitialLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    fireServ = Provider.of<FirestoreService>(context);
    getFriends();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.changePage(1),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: [

            SafeArea(child: getMap()),


            Positioned(
              left: 5, top:5,
              child: SafeArea(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 25,
                      onPressed: () => widget.changePage(1),
                    )
                ),
              ),
            ),

        ]
        ),
      ),
    );
  }

  getInitLocation() {
    return CameraPosition(zoom: 14.4746, target: LatLng(currentLocation.latitude, currentLocation.longitude));
  }

  void setInitialLocation() async {
    var locationData = await location.getLocation();
    setState(() {
      currentLocation = locationData;
    });

  }

  Widget getMap() {
    return currentLocation == null ? Container() : GoogleMap(
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
      markers: _markers,
      compassEnabled: false,
      initialCameraPosition: getInitLocation(),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        showPinsOnMap();
      },
    );
  }

  void showPinsOnMap() async{
    if (friendInboxes == null || friendInboxes.isEmpty) return;

    for (InboxUserData data in friendInboxes) {

      var pinPosition = LatLng(data.inboxEntrys.first.latitude, data.inboxEntrys.first.longitude);
      CacheUtil.getCachedOrHttpImageBytes(data.userData.photo).then((bytes){
        addUserToMarker(bytes, data.userData.uid, pinPosition, data.inboxEntrys.first);
      });

    }

  }

  Future<Uint8List> getImageFromBytesSize(Uint8List bytes, int height) async {
    var image = decodeImage(bytes);
    var originalH = image.height;
    var originalW = image.width;
    image = copyResizeCropSquare(image, height);


    if (originalH < originalW) image = copyRotate(image, 90); //TODO TEMP BUG?


    Uint8List imageBytesResized = Uint8List.fromList(encodePng(image));

    //bytes to ui.Image
    Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(imageBytesResized, (result) {
      completer.complete(result);
    });

    ui.Image imageDone = await completer.future;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);


    final radius = 10.0; //20 diameter
    final circleImageMargin = 30;
    final center = Offset(imageDone.width / 2, (imageDone.height + circleImageMargin).toDouble());

    // The circle should be paint before or it will be hidden by the path
    Paint paintCircle = Paint()..color = Colors.black;
    Paint paintBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, paintBorder);

    var drawImageWidth = 0.0;
    var drawImageHeight =  0.0;
    Path path = Path()..addOval(Rect.fromLTWH(drawImageWidth, drawImageHeight, imageDone.width.toDouble(), imageDone.height.toDouble()));
    canvas.clipPath(path);

    canvas.drawImage(imageDone, Offset(drawImageWidth, drawImageHeight), Paint());

    final img = await pictureRecorder.endRecording().toImage(imageDone.width, (imageDone.height + (radius * 2) + circleImageMargin).ceil());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  void getFriends() async{
    fireServ.getFriends(userData.uid).then((value) {

      if (value.data() != null) {

        List<Future<DocumentSnapshot>> fUserDatas = [];
        var list = value.data()["uids"];
        for (String uid in list) {
          fUserDatas.add(fireServ.getUser(uid));
        }

        Future.wait(fUserDatas).then((value) {
          friendsData = value.map((e) => FireSerialize.toUserData(e.data())).toList();
          //also current user
          friendsData.add(userData);

          List<Future<DocumentSnapshot>> fInboxes = [];
          for (UserData data in friendsData) {
            fInboxes.add(fireServ.getInbox(data.uid));
          }


          Future.wait(fInboxes).then((value) {
            for (DocumentSnapshot snap in value) {
              if (snap.data() == null) continue;
              List<dynamic> inboxList = snap.data()["inbox"];

              String uid = snap.id;
              var map = inboxList.last;
              var drink = map["drink"];
              var photo = map["photo"];
              var date = map["date"];
              var long = map["long"];
              var lat = map["lat"];

              // latest entry only
              List<InboxEntry> userInboxes = [InboxEntry(date: DateTime.parse(date), photo: photo, drink: drink, latitude: lat, longitude: long)];
              var inboxUserData = InboxUserData(inboxEntrys: userInboxes, userData: friendsData.firstWhere((element) => element.uid == uid),);
              friendInboxes.add(inboxUserData);
            }

            if (_controller.isCompleted) {
              showPinsOnMap();
            } else {
              return;
            }

          });

        });

      }
    });
  }

  void addUserToMarker(Uint8List bytes, String uid, LatLng pinPosition, InboxEntry inboxEntry) {
    getImageFromBytesSize(bytes, 150).then((bytes){
      setState(() {
        _markers.add(
            Marker(
                onTap: () => onMarkerTap(uid, inboxEntry),
                markerId: MarkerId(uid),
                position: pinPosition,
                icon: BitmapDescriptor.fromBytes(bytes)));
      });
    });
  }

  void onMarkerTap(String uid, InboxEntry inboxEntry) {
    UserData user = friendsData.firstWhere((element) => element.uid == uid);

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              height: (56 * 6).toDouble(),
              child: Column(children: [
                SizedBox(height:20),
                Text(user.displayName + " is drinking " + inboxEntry.drink, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                getDateText(inboxEntry.date),
                SizedBox(height: 20,),
                getImageThumb(inboxEntry.photo),
              ],)
            ),
          );
        }
    );

  }

  Widget getDateText(DateTime date) {
    Duration diff = date.difference(DateTime.now()).abs();
    int h = diff.inHours;
    int m = diff.inMinutes;

    String dateText = "";
    if (h != 0) {
      dateText = h.toString() + " hours and ";
      m = m - (60*h);
    }
    dateText = dateText + m.toString() + " minutes ago";

    return Text(dateText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54),);
  }

  Widget getImageThumb(String photo) {
    return Thumbnail(
      dataResolver: () async {
        return CacheUtil.getCachedOrHttpImageBytes(photo);
        },
      mimeType: "image/" + "png",
      widgetSize: 220,
    );

  }


}
