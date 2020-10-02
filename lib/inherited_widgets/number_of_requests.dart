import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snap_shots/service/firestore.dart';

class NrOfRequests with ChangeNotifier{

  NrOfRequests({this.uid, this.fireServ});

  int _nrOfRequests = 0;
  FirestoreService fireServ;
  String uid;


  void updateNrOfRequests() {
    fireServ.getFriendStatus(uid).then((value) {
      List<String> requests = [];
      if (value.data() != null) {
        var maps = value.data()["uids"];
        for(dynamic map in maps) {
          if(map["accepted"] == false) requests.add(map["from"]);
        }
      }

      _nrOfRequests = requests.length;
      notifyListeners();
    });
  }

  Widget getFriendReqIcon(Widget bottomWidget) {
    if(_nrOfRequests > 0) {
      return Stack(
          children : [
            bottomWidget,
            UnconstrainedBox(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.red,
                ),
                child: Center(child: Text(_nrOfRequests.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
              ),
            )
          ]);
    } else {
      return bottomWidget;
    }
  }

  void decrement() {
    _nrOfRequests = _nrOfRequests - 1;
    notifyListeners();
  }


}