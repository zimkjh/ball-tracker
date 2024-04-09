import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  final cameraController = Rx<CameraController?>(null);

  final _isCameraInitialized = false.obs;
  bool get isCameraInitialized => _isCameraInitialized.value;

  @override
  void onInit() async {
    super.onInit();

    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    cameraController.value = CameraController(
      firstCamera,
      ResolutionPreset.ultraHigh,
    );
    await cameraController.value?.initialize();
    _isCameraInitialized.value = true;
  }

  void increment() => count.value++;
}
