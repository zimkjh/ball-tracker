class DetectedObject {
  double left;
  double top;
  double width;
  double height;
  String name;
  double score;

  DetectedObject({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.name,
    required this.score,
  });
}
