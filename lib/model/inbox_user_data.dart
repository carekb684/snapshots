import 'package:snap_shots/model/inbox_model.dart';

import 'UserData.dart';

class InboxUserData {
  InboxUserData({this.userData, this.inboxEntrys});

  UserData userData;
  List<InboxEntry> inboxEntrys;
}