import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      body: Stack(
        children: [
          SizedBox(
            width: Get.width,
            child: Obx(() {
              if (controller.isCameraInitialized) {
                return CameraPreview(controller.cameraController.value!);
              } else {
                return const SizedBox.shrink();
              }
            }),
          ),
          Obx(() {
            if (controller.detectedObjects.isEmpty) {
              return const SizedBox.shrink();
            }
            return Stack(
              children: controller.detectedObjects
                  .map<Widget>((detectedObject) => Positioned(
                        left: detectedObject.left,
                        top: detectedObject.top,
                        width: detectedObject.width,
                        height: detectedObject.height,
                        child: Container(
                          width: detectedObject.width,
                          height: detectedObject.height,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue.withOpacity(
                                detectedObject.score,
                              ),
                              width: 3,
                            ),
                          ),
                          child: Text(
                            detectedObject.name,
                            style: TextStyle(
                              color: Colors.blue.withOpacity(
                                detectedObject.score,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
