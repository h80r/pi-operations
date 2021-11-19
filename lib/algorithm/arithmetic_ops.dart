import 'dart:typed_data';
import 'package:image/image.dart';

Uint8List sum(
  Uint8List pixelsImgA,
  Uint8List pixelsImgB,
  int resultImageLength,
) {
  Uint8List resultImagePixels = Uint8List(resultImageLength);
  int sum;

  for (var i = 0; i < resultImageLength; i++) {
    sum = pixelsImgA[i] + pixelsImgB[i];
    resultImagePixels[i] = sum.clamp(0, 255);
  }

  return resultImagePixels;
}

Uint8List subtraction(
  Uint8List pixelsImgA,
  Uint8List pixelsImgB,
  int resultImageLength,
) {
  Uint8List resultImagePixels = Uint8List(resultImageLength);
  int sub;

  for (var i = 0; i < resultImageLength; i++) {
    sub = pixelsImgA[i] - pixelsImgB[i];
    resultImagePixels[i] = sub.abs();
  }
  return resultImagePixels;
}

Uint8List multiplication(
  Uint8List pixelsImgA,
  Uint8List pixelsImgB,
  int resultImageLength,
) {
  Uint8List resultImagePixels = Uint8List(resultImageLength);
  double mult;

  for (var i = 0; i < resultImageLength; i++) {
    mult = (pixelsImgA[i] / 255) * (pixelsImgB[i] / 255);
    resultImagePixels[i] = (mult * 255).toInt();
  }
  return resultImagePixels;
}

Uint8List division(
  Uint8List pixelsImgA,
  Uint8List pixelsImgB,
  int resultImageLength,
) {
  Uint8List resultImagePixels = Uint8List(resultImageLength);
  double div;

  for (var i = 0; i < resultImageLength; i++) {
    div = (pixelsImgA[i] / 255) / (pixelsImgB[i] / 255);
    resultImagePixels[i] = (div * 255).toInt();
  }
  return resultImagePixels;
}

Uint8List? operate(Uint8List? imageA, Uint8List? imageB, dynamic operation) {
  Uint8List reformat(Map<String, int> measurements, Uint8List processedImage) {
    return Uint8List.fromList(
      encodePng(
        Image.fromBytes(
          measurements['width'] ?? 0,
          measurements['height'] ?? 0,
          processedImage,
          format: Format.rgb,
        ),
      ),
    );
  }

  Image imgA = decodeImage(imageA!)!;
  Image imgB = decodeImage(imageB!)!;

  Uint8List pixelsImgA = imgA.getBytes(format: Format.rgb);
  Uint8List pixelsImgB = imgB.getBytes(format: Format.rgb);

  int resultImageLength = pixelsImgA.length <= pixelsImgB.length
      ? pixelsImgA.length
      : pixelsImgB.length;

  final smallestImg = pixelsImgA.length <= pixelsImgB.length ? imgA : imgB;
  final measurements = {
    'width': smallestImg.width,
    'height': smallestImg.height,
  };

  return reformat(
      measurements,
      operation(
        pixelsImgA,
        pixelsImgB,
        resultImageLength,
      ));
}