import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: SizedBox(
        width: Get.width,
        child: Obx(() {
          if (controller.isCameraInitialized) {
            return CameraPreview(controller.cameraController.value!!);
          } else {
            return const SizedBox.shrink();
          }
        }),
      ),
    );
  }
}
