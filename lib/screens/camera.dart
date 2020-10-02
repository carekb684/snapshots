import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:snap_shots/model/UserData.dart';
import 'package:snap_shots/screens/send_pic.dart';

class Camera extends StatefulWidget {
  Camera({this.changePage});
  Function changePage;

  @override
  _CameraState createState() => _CameraState();
}



class _CameraState extends State<Camera> with AutomaticKeepAliveClientMixin<Camera>{

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CameraDescription> cameras;
  CameraController controller;
  int cameraView = 0; // 0 == normal, 1 == selfie.

  String imagePath;
  File imgFile;

  UserData userData;

  FlutterFFmpeg _FFmpeg = new FlutterFFmpeg();

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
      controller = CameraController(cameras[cameraView], ResolutionPreset.veryHigh);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
  }

  @override
  Widget build(BuildContext context) {

    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return Scaffold(
      key: _scaffoldKey,
      body: getCameraView(),
    );

  }


  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SendPic(imagePath: filePath)));
      }
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    String filePath = '$dirPath/${timestamp()}.jpg';

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


    if(cameraView == 1) {
      await _FFmpeg.execute("-y -i " +
          filePath +
          " -vf transpose=3 " +
          filePath);
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
          left: 10, top:10,
          child: SafeArea(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50 / 2)),
                border: Border.all(
                  color: Colors.white,
                  width: 4.0,
                ),
                ),
              child: ClipOval(
                child: InkWell(
                  onTap: onClickUser,
                  child: CachedNetworkImage(
                    imageUrl: userData.photo == null ? "" : userData.photo,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/avatar.png"), fit: BoxFit.fill)),),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: 10, top:10,
          child: SafeArea(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: IconButton(
                  icon: Icon(Icons.switch_camera, color: Colors.white),
                  iconSize: 25,
                  onPressed: toggleCameraView,
                )
            ),
          )
        ),

      ],
    );
  }


  void onClickUser() {
    widget.changePage(0);
  }

  @override
  bool get wantKeepAlive => true;

  void toggleCameraView() async {

    if (cameraView == 0 ) {
      if (cameras.length == 1){
        showInSnackBar("Selfie camera not found");
        return;
      }
      cameraView = 1;
    } else {
      cameraView = 0;
    }

    //get rid of current camera
    if (controller != null) {
      await controller.dispose();
    }


    controller = CameraController(cameras[cameraView], ResolutionPreset.veryHigh);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }

  }
}
