import 'package:ball_tracker/app/utils/image_utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  final cameraController = Rx<CameraController?>(null);

  final _isCameraInitialized = false.obs;
  bool get isCameraInitialized => _isCameraInitialized.value;

  late Interpreter interpreter;
  final List<List<int>> _outputShapes = [];
  final List<TensorType> _outputTypes = [];

  List<String> _labels = [];

  bool predicting = false;

  @override
  void onInit() async {
    super.onInit();

    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();

    cameraController.value = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );
    if (cameraController.value != null) {
      await cameraController.value!.initialize();
      _isCameraInitialized.value = true;

      interpreter = await Interpreter.fromAsset("assets/detect.tflite");
      final outputTensors = interpreter.getOutputTensors();
      for (var tensor in outputTensors) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }

      _labels =
          (await rootBundle.loadString("assets/labelmap.txt")).split("\n");

      await cameraController.value!.startImageStream(onLatestImageAvailable);
    }
  }

  onLatestImageAvailable(CameraImage cameraImage) async {
    if (predicting) {
      return;
    }

    predicting = true;

    var outputs = <int, List<dynamic>>{};
    for (var i = 0; i < _outputShapes.length; i++) {
      outputs[i] = List.filled(_outputShapes[i].reduce((v, e) => v * e), 0)
          .reshape(_outputShapes[i]);
    }

    final image = await convertCameraImageToImage(cameraImage);
    final imageInput = copyResize(image!, width: 300, height: 300);
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    interpreter.runForMultipleInputs([
      [imageMatrix]
    ], outputs);

    debugPrint(outputs.toString());

    // predicting = false;
  }
}
