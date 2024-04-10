import 'package:ball_tracker/app/data/detected_object.dart';
import 'package:ball_tracker/app/utils/image_utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeController extends GetxController {
  static const inputSize = 300;
  final count = 0.obs;

  final cameraController = Rx<CameraController?>(null);

  final _isCameraInitialized = false.obs;
  bool get isCameraInitialized => _isCameraInitialized.value;

  late Interpreter interpreter;
  final List<List<int>> _outputShapes = [];
  final List<TensorType> _outputTypes = [];

  List<String> _labels = [];

  bool predicting = false;

  final _detectedObjects = Rx<List<DetectedObject>>([]);
  List<DetectedObject> get detectedObjects => _detectedObjects.value;

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
    final imageInput = copyResize(image!, width: inputSize, height: inputSize);
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

    final height = Get.width * (cameraImage.height / cameraImage.width);
    _detectedObjects.value = List.generate(
      10,
      (i) => DetectedObject(
        left: (outputs[0] as List)[0][i][1] * Get.width,
        top: (outputs[0] as List)[0][i][0] * height,
        width: ((outputs[0] as List)[0][i][3] - (outputs[0] as List)[0][i][1]) *
            Get.width,
        height:
            ((outputs[0] as List)[0][i][2] - (outputs[0] as List)[0][i][0]) *
                height,
        name: _labels[(outputs[1] as List)[0][i].toInt()],
        score: (outputs[2] as List)[0][i],
      ),
    );

    predicting = false;
  }
}
