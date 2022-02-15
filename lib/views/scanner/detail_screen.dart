import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:src/shared/custom_style.dart';

class DetailScreen extends StatefulWidget {
  final imagePath;
  final textDetector;
  const DetailScreen({this.imagePath, this.textDetector});
  @override
  _DetailScreenState createState() => _DetailScreenState(imagePath, textDetector);
}

class _DetailScreenState extends State<DetailScreen> {
  String _imagePath;
  TextDetector _textDetector;
  Size _imageSize;
  List<TextElement> _elements = [];

  List<String> _listpresStrings;

  _DetailScreenState(this._imagePath, this._textDetector);

  // Fetching the image size from the image file
  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();
    final Image image = Image.file(imageFile);

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;

    setState(() {
      _imageSize = imageSize;
    });
  }

  // To detect the presc present in an image
  void _recognizePrescription() async {
    _getImageSize(File(_imagePath));

    // Creating an InputImage object using the image path
    final inputImage = InputImage.fromFilePath(_imagePath);
    // Retrieving the RecognisedText from the InputImage
    final text = await _textDetector.processImage(inputImage);

   

    String pattern1 = ' 1--*1--*1';
    String pattern2 = ' 1--*1--*0';
    String pattern3 = ' 1--*0--*1';
    String pattern4 = ' 1--*0--*0';
    String pattern5 = ' 0--*1--*1';
    String pattern6 = ' 0--*1--*0';
    String pattern7 = ' 0--*0--*1';

    RegExp regEx1 = RegExp(pattern1);
    RegExp regEx2 = RegExp(pattern2);
    RegExp regEx3 = RegExp(pattern3);
    RegExp regEx4 = RegExp(pattern4);
    RegExp regEx5 = RegExp(pattern5);
    RegExp regEx6 = RegExp(pattern6);
    RegExp regEx7 = RegExp(pattern7);
    List<String> presStrings = [];

    // Finding and storing the text String(s) and the TextElement(s)
    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        print('text: ${line.text}');
        if (regEx1.hasMatch(line.text)||regEx2.hasMatch(line.text)||regEx3.hasMatch(line.text)||regEx4.hasMatch(line.text)||regEx5.hasMatch(line.text)||regEx6.hasMatch(line.text)||regEx7.hasMatch(line.text)) {
          presStrings.add(line.text);
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
      }
    }
    print('prescription string: $presStrings');
    print('elements: $_elements');
    setState(() {
      _listpresStrings = presStrings;
    });
  }

  @override
  void initState() {
    _imagePath = widget.imagePath;
    // Initializing the text detector
    _textDetector = GoogleMlKit.vision.textDetector();
    _recognizePrescription();
    super.initState();
  }

  @override
  void dispose() {
    // Disposing the text detector when not used anymore
    _textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: butcolor,
        centerTitle: true,

        title: Text("Image Details", style: TextStyle(color: bgcolor),),
        iconTheme: IconThemeData(color: bgcolor),
      ),
      body: _imageSize != null
          ? Stack(
        children: [
          Container(
            width: double.maxFinite,
            color: Colors.black,
            child: CustomPaint(
              foregroundPainter: TextDetectorPainter(
                _imageSize,
                _elements,
              ),
              child: AspectRatio(
                aspectRatio: _imageSize.aspectRatio,
                child: Image.file(
                  File(_imagePath),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              elevation: 8,
              color: butcolor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Identified precriptions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      child: SingleChildScrollView(
                        child: _listpresStrings != null
                            ? ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: _listpresStrings.length,
                          itemBuilder: (context, index) =>
                              Text(_listpresStrings[index]),
                        )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
          : Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// Helps in painting the bounding boxes around the recognized
// email addresses in the picture
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextElement container) {
      return Rect.fromLTRB(
        container.rect.left * scaleX,
        container.rect.top * scaleY,
        container.rect.right * scaleX,
        container.rect.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}