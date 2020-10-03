import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/model/UserData.dart';

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
  Location location;

  UserData userData;

  @override
  void initState() {
    super.initState();
    location = new Location();
    location.changeSettings(interval: 30 * 1000);
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;


      //updatePinOnMap();

    });

    setInitialLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
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
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: getInitLocation(),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        //showPinsOnMap();
      },
    );
  }

}
