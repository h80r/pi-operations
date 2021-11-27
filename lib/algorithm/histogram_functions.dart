import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:pi_papers_2021_2/utils/histogram_utils.dart';
import 'package:pi_papers_2021_2/utils/image_utils.dart';

typedef HistogramData = Map<int, num>;
typedef HistogramResult = Tuple<HistogramData, Uint8List?>;
typedef HistogramFunction = HistogramResult Function(Uint8List luminanceList);

/// Reads the provided image, and returns the
/// luminance value of each pixel as a list.
Uint8List getLuminanceValues(Image decodedImage) {
  return decodedImage.getBytes(format: Format.luminance);
}

/// Returns the result of the histogram operation with an image.
///
/// The histogram is calculated by the [operation] function.
/// If the operation generates a new image, it will be encoded by this function.
HistogramResult? operate(Uint8List? image, HistogramFunction? operation) {
  if (image == null || operation == null) return null;

  final decodedImage = decodeImage(image)!;
  final luminanceList = getLuminanceValues(decodedImage);

  final result = operation(luminanceList);

  if (result.get<Uint8List?>() == null) return result;
  return result.copyWith(
    second: reformat(
      width: decodedImage.width,
      height: decodedImage.height,
      processedImage: result.get<Uint8List?>()!,
      format: Format.luminance,
    ),
  );
}

/// Creates a Map associating each pixel value
/// to its frequency (quantity) in image.
///
/// Parameters:
/// - `luminanceList`: uploaded image.
///
/// Returns:
/// - A tuple with it's Uint8List as a null value and a map containing each
/// pixel value associated to its frequency in `luminanceList`.
HistogramResult histogramGeneration(Uint8List luminanceList) {
  final intensityFrequency = <int, num>{};

  for (final v in luminanceList) {
    intensityFrequency.update(v, (value) => value + 1, ifAbsent: () => 1);
  }

  return Tuple(intensityFrequency, null);
}

HistogramResult normalizedHistogram(Uint8List luminanceList) {
  final histogramData = histogramGeneration(luminanceList).get<Map<int, num>>();

  final pixelCount = luminanceList.length;
  final normalizedFrequency = histogramData!.map(
    (key, value) => MapEntry(key, value / pixelCount),
  );

  return Tuple(normalizedFrequency, null);
}

HistogramResult histogramEqualization(Uint8List luminanceList) {
  // TODO: Process the image accordingly
  final processedPixelList = luminanceList;
  return Tuple({}, processedPixelList);
}

HistogramResult contrastStreching(Uint8List luminanceList) {
  final oldHistogram = histogramGeneration(luminanceList).get<Map<int, num>>();

  const smallerIntervalValue = 0;
  const biggerIntervalValue = 255;

  final smallerImageValue = oldHistogram!.keys.toList().reduce(min);
  final biggerImageValue = oldHistogram.keys.toList().reduce(max);

  final newHistogram = oldHistogram.map((key, value) => MapEntry(
        ((key - smallerImageValue) *
                    ((biggerIntervalValue - smallerIntervalValue) /
                        (biggerImageValue - smallerImageValue)) +
                smallerIntervalValue)
            .toInt(),
        value,
      ));

  final luminanceMap = Map.fromIterables(oldHistogram.keys, newHistogram.keys);
  final processedPixelList = Uint8List.fromList(
    luminanceList.map((e) => luminanceMap[e]!).toList(),
  );

  return Tuple(newHistogram, processedPixelList);
}
