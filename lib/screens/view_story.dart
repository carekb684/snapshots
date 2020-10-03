import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:snap_shots/model/inbox_model.dart';
import 'package:snap_shots/model/inbox_user_data.dart';
import 'package:story_viewer/story_viewer.dart';

class ViewStories extends StatefulWidget {
  ViewStories({this.users, this.startIndex});

  List<InboxUserData> users;
  int startIndex;

  @override
  _ViewStoriesState createState() => _ViewStoriesState(startIndex);
}

class _ViewStoriesState extends State<ViewStories> {

  _ViewStoriesState(int startIndex) {
    this.startIndex = startIndex;
    this.verticalController = PageController(initialPage: startIndex);
  }
  int startIndex;
  PageController verticalController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: verticalController,
        scrollDirection: Axis.horizontal,
        children: getStoryViewers(),
      )
    );
  }

  List<StoryItemModel> getStoryList(InboxUserData inbox) {
    List<StoryItemModel> stories = [];

    for (InboxEntry entry in inbox.inboxEntrys) {
      //stories.add(StoryItemModel(url: entry.photo));
      stories.add(StoryItemModel(imageProvider: CachedNetworkImageProvider(entry.photo,)));
    }
    return stories;
  }

  List<Widget> getStoryViewers() {
    List<Widget> storyViewers = [];
    for (InboxUserData inbox in widget.users) {
      storyViewers.add(
          StoryViewer(
            stories: getStoryList(inbox),
            userModel: UserModel(
              username: inbox.userData.displayName,
              profilePictureUrl: inbox.userData.photo,
        ),
      ));
    }
    return storyViewers;
  }
}
