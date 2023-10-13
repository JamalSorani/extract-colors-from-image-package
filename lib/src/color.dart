import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ColorDetection {
  final GlobalKey currentKey;
  final StreamController<Color> stateController;
  final GlobalKey paintKey;

  img.Image? photo;

  ColorDetection({
    Key? key,
    required this.currentKey,
    required this.stateController,
    required this.paintKey,
  });
  Future<dynamic> searchPixel(Offset globalPosition) async {
    if (photo == null) {
      await loadSnapshotBytes();
    }
    return _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset globalPosition) {
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    int a = photo!.getPixelSafe(px.toInt(), py.toInt()).a as int;
    int b = photo!.getPixelSafe(px.toInt(), py.toInt()).b as int;
    int g = photo!.getPixelSafe(px.toInt(), py.toInt()).g as int;
    int r = photo!.getPixelSafe(px.toInt(), py.toInt()).r as int;
    int hex = (a << 24) | (r << 16) | (g << 8) | b;

    stateController.add(Color(hex));
  }

  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint =
        paintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image capture = await boxPaint.toImage();
    ByteData? imageBytes =
        await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes!);
    capture.dispose();
  }

  void setImageBytes(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();

    photo = img.decodeImage(values as Uint8List)!;
  }
}

class PaletteColorItem extends StatefulWidget {
  const PaletteColorItem({super.key, required this.color});
  final Color color;
  @override
  State<PaletteColorItem> createState() => _PaletteColorItemState();
}

class _PaletteColorItemState extends State<PaletteColorItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 60,
            width: 30,
          ),
          IconButton(
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(0),
            ),
            onPressed: () {
              FlutterClipboard.copy('${widget.color}');
            },
            icon: const Icon(
              Icons.copy,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
