import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Prediction {
  final int id;
  final double prob;
  const Prediction(this.id, this.prob);
}

class ClassifyResult {
  final List<Prediction> top3;
  final double inferenceMs; // chỉ thời gian chạy mô hình
  final double totalMs; // tiền xử lý + chạy mô hình
  final Uint8List preview; // ảnh vùng đã cắt (PNG) để hiển thị
  const ClassifyResult(this.top3, this.inferenceMs, this.totalMs, this.preview);
}

/// Bộ phân loại dùng mô hình CNN đã chuyển sang TensorFlow Lite.
/// Xử lý ảnh giống traffic_sign.py: ảnh RGB, 30x30, giữ giá trị điểm ảnh 0-255.
class Classifier {
  static const int inputSize = 30;
  static const int numClasses = 43;
  static Interpreter? _interpreter;

  static Future<void> load() async {
    _interpreter ??= await Interpreter.fromAsset('assets/model.tflite');
  }

  static Future<ClassifyResult> classify(img.Image crop) async {
    await load();
    final total = Stopwatch()..start();

    final rgb = crop.convert(format: img.Format.uint8, numChannels: 3);
    final small = img.copyResize(rgb, width: inputSize, height: inputSize, interpolation: img.Interpolation.cubic);

    final input = [
      List.generate(inputSize, (y) => List.generate(inputSize, (x) {
            final p = small.getPixel(x, y);
            return [p.r.toDouble(), p.g.toDouble(), p.b.toDouble()];
          }))
    ];
    final output = [List<double>.filled(numClasses, 0.0)];

    final infer = Stopwatch()..start();
    _interpreter!.run(input, output);
    infer.stop();
    total.stop();

    final probs = output[0];
    final order = List<int>.generate(numClasses, (i) => i)..sort((a, b) => probs[b].compareTo(probs[a]));
    final top3 = order.take(3).map((i) => Prediction(i, probs[i])).toList();

    final previewImg = img.copyResize(rgb, width: 240, height: 240, interpolation: img.Interpolation.cubic);
    final preview = Uint8List.fromList(img.encodePng(previewImg));

    return ClassifyResult(top3, infer.elapsedMicroseconds / 1000.0, total.elapsedMicroseconds / 1000.0, preview);
  }
}
