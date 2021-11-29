import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pi_papers_2021_2/widgets/input/finish_button.dart';
import 'package:pi_papers_2021_2/widgets/input/image_selector.dart';
import 'package:pi_papers_2021_2/widgets/structure/footer.dart';
import 'package:pi_papers_2021_2/widgets/structure/header.dart';
import 'package:pi_papers_2021_2/widgets/histogram_graph.dart';
import 'package:pi_papers_2021_2/widgets/input/styled_dropdown.dart';

import 'package:pi_papers_2021_2/algorithm/histogram_functions.dart';

class HistogramPage extends HookWidget {
  const HistogramPage({Key? key}) : super(key: key);

  final menu = const {
    'Histograma': histogramGeneration,
    'Histograma normalizado': normalizedHistogram,
    'Equalização de histograma': histogramEqualization,
    'Efeitos de Contrast Stretching': contrastStretching,
  };

  @override
  Widget build(BuildContext context) {
    var inputImage = useState<Uint8List?>(null);
    var dropdownCurrentValue = useState<String?>(menu.keys.first);
    var operation = useState<HistogramFunction?>(null);
    var histogramResult = useState<HistogramResult?>(null);

    final resultImage = histogramResult.value?.get<Uint8List?>();
    final histogramData = histogramResult.value?.get<HistogramData>();

    return Scaffold(
      appBar: const Header(
        title: 'Processar Histogramas',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    ImageSelector(
                      isResult: false,
                      image: inputImage.value != null
                          ? Image.memory(inputImage.value!)
                          : null,
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile == null) return;
                        final fileBytes = await pickedFile.readAsBytes();
                        inputImage.value = fileBytes;
                      },
                    ),
                    if (resultImage != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: ImageSelector(
                          isResult: true,
                          image: Image.memory(resultImage),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    StyleDropdown(
                      items: menu.keys.toList(),
                      value: dropdownCurrentValue.value,
                      onChanged: (newValue) {
                        dropdownCurrentValue.value = newValue;
                        operation.value = menu[newValue];
                      },
                    ),
                    FinishButton(
                      text: 'GO',
                      isCompact: true,
                      onPressed: () {
                        operation.value = menu[dropdownCurrentValue.value];
                        histogramResult.value = operate(
                          inputImage.value,
                          operation.value,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (histogramData != null)
              HistogramGraph(intensityFrequency: histogramData),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
