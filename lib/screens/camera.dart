import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}



class _CameraState extends State<Camera> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CameraDescription> cameras;
  CameraController controller;

  String imagePath;
  File imgFile;

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();

    availableCameras().then((value){
      cameras = value;
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return Scaffold(
      key: _scaffoldKey,
      body: imagePath == null ? getCameraView() : getImageView(),
      bottomNavigationBar: imagePath == null ? null : createBottomBar(),
    );

  }


  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
      }
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }




  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  Widget getCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller)),

        Positioned.fill(
          bottom: 40,
          child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: IconButton(
                icon: Icon(Icons.local_drink, color: Colors.white,),
                iconSize: 70,
                onPressed: onTakePictureButtonPressed,
              )),
        ),


        Positioned(
          right: 5, top:5,
          child: SafeArea(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  //icon: Icon(Icons.close, color: Colors.white),
                  iconSize: 25,
                  onPressed: () {

                  },
                )
            ),
          ),
        )

      ],
    );
  }

  Widget getImageView() {
    return Stack(
      fit: StackFit.expand,
        children: [

          Image.file(saveImg(), fit:BoxFit.fill,),

          Positioned(
            left: 5, top:5,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  iconSize: 25,
                  onPressed: closeImagePressed,
                )
              ),
            ),
          )
        ]
    );
  }

  File saveImg() {
    imgFile = File(imagePath);
    return imgFile;
  }

  void closeImagePressed() {
    imgFile.deleteSync();
    setState(() {
      imagePath = null;
    });
  }

  Widget createBottomBar() {
    return BottomAppBar(
      elevation: 0,
      child: getBottomBarComponents(showMenu),
    );
  }










  showMenu() {

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: Theme.of(context).primaryColorDark,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 36,
                ),
                SizedBox(
                    height: (56 * 6).toDouble(),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              top: -36,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                    border: Border.all(
                                        color: Theme.of(context).primaryColorDark, width: 10)),
                                child: Center(
                                  child: ClipOval(
                                    child: Image.network(
                                      "https://i.stack.imgur.com/S11YG.jpg?s=64&g=1",
                                      fit: BoxFit.cover,
                                      height: 36,
                                      width: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      "Inbox",
                                    ),
                                    leading: Icon(
                                      Icons.inbox,
                                    ),
                                    onTap: () {},
                                  ),
                                  ListTile(
                                    title: Text(
                                      "Starred",
                                    ),
                                    leading: Icon(
                                      Icons.star_border,
                                    ),
                                    onTap: () {},
                                  ),

                                ],
                              ),
                            )
                          ],
                        ))),

                getBottomBarComponents(() => Navigator.pop(context)),

              ],
            ),
          );
        });
  }

  Widget getBottomBarComponents(Function burgerPressed) {
    return Container(
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: 56.0,
      child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: burgerPressed,
              icon: Icon(Icons.menu),
              color: Colors.black,
            ),

            Text("Select a drink before sending", style: TextStyle(color: Colors.black),),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.send),
              color: Colors.black,
            )
          ]),
    );
  }









}
