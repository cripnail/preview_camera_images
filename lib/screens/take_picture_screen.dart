import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gallery_screen.dart';

class TakePictureScreen extends StatefulWidget {
  final String title;

  const TakePictureScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  late final List<CameraDescription> cameras;
  CameraController? controller;
  XFile? lastImage;
  List<File> capturedImages = [];

  @override
  void initState() {
    super.initState();
    unawaited(initCamera());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController != null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    await controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: MaterialApp(
          home: Stack(
            children: [
              controller?.value.isInitialized == true
                  ? Center(child: CameraPreview(controller!))
                  : const SizedBox(),
              if (lastImage != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (capturedImages.isEmpty) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GalleryScreen(
                                      images:
                                          capturedImages.reversed.toList())));
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 2.0)),
                            width: 120.0,
                            height: 240.0,
                            child: Image.file(File(lastImage!.path),
                                fit: BoxFit.cover)),
                      )),
                ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 98.0),
                    child: IconButton(
                      iconSize: 48.0,
                      onPressed: () async {
                        lastImage = await controller?.takePicture();
                        setState(() {
                          capturedImages.add(File(lastImage!.path));
                        });
                      },
                      icon: const Icon(Icons.camera),
                    ),
                  ))
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    await controller?.dispose();
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }
}
