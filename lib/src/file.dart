import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import '/src/color.dart';

class FileImageBG extends StatefulWidget {
  final Color backgroundColor;

  const FileImageBG({super.key, required this.backgroundColor});

  @override
  FileImageBGState createState() => FileImageBGState();
}

class FileImageBGState extends State<FileImageBG> {
  File? filePath;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();
  bool useSnapshot = true;
  late GlobalKey currentKey;
  List<PaletteColor> colorsList = [];
  final StreamController<Color> stateController = StreamController<Color>();
  bool isLoading = false;
  @override
  void initState() {
    currentKey = useSnapshot ? paintKey : imageKey;
    if (filePath != null) {
      addPaletteColors();
    }
    super.initState();
  }

  File? _selectedImage;
  void _takePicture() async {
    setState(() {
      isLoading = true;
    });
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      setState(() {
        isLoading = false;
      });

      return;
    }
    setState(() {
      colorsList = [];
      _selectedImage = File(pickedImage.path);
      filePath = _selectedImage!;
      addPaletteColors();
    });
  }

  Color? dom;
  void addPaletteColors() async {
    final PaletteGenerator pg = await PaletteGenerator.fromImageProvider(
      FileImage(filePath!),
      size: const Size(200, 200),
    );
    if (pg.darkMutedColor != null) {
      colorsList.add(pg.darkMutedColor ?? PaletteColor(Colors.white, 2));
    }
    if (pg.darkVibrantColor != null) {
      colorsList.add(pg.darkVibrantColor ?? PaletteColor(Colors.white, 2));
    }
    if (pg.dominantColor != null) {
      colorsList.add(pg.dominantColor ?? PaletteColor(Colors.white, 2));
      dom = pg.dominantColor!.color;
    }
    if (pg.lightMutedColor != null) {
      colorsList.add(pg.lightMutedColor ?? PaletteColor(Colors.white, 2));
    }
    if (pg.lightVibrantColor != null) {
      colorsList.add(pg.lightVibrantColor ?? PaletteColor(Colors.white, 2));
    }
    if (pg.mutedColor != null) {
      colorsList.add(pg.mutedColor ?? PaletteColor(Colors.white, 2));
    }
    if (pg.vibrantColor != null) {
      colorsList.add(pg.vibrantColor ?? PaletteColor(Colors.white, 2));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder(
            stream: stateController.stream,
            builder: (buildContext, snapshot) {
              Color selectedColor = snapshot.data ?? dom ?? Colors.black;
              return Column(
                children: [
                  filePath == null
                      ? Container(
                          color: Colors.black,
                          height: height * 0.45,
                          width: double.maxFinite,
                          child: TextButton.icon(
                            onPressed: _takePicture,
                            label: const Text(
                              'Click to add an image',
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: const Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : RepaintBoundary(
                          key: paintKey,
                          child: GestureDetector(
                            onPanDown: (details) {
                              ColorDetection(
                                currentKey: currentKey,
                                paintKey: paintKey,
                                stateController: stateController,
                              ).searchPixel(details.globalPosition);
                            },
                            child: Image.file(
                              filePath!,
                              key: imageKey,
                              fit: BoxFit.fill,
                              height: height * 0.45,
                              width: double.maxFinite,
                            ),
                          ),
                        ),
                  SizedBox(height: height * 0.01),
                  filePath != null
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: selectedColor),
                          onPressed: _takePicture,
                          label: const Text(
                            'Select other image',
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: const Icon(
                            Icons.image,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(height: height * 0.01),
                  colorsList.isNotEmpty || isLoading
                      ? Card(
                          elevation: 7,
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: selectedColor,
                                  ),
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: 10, height: height * 0.08),
                                        const Text(
                                          'Palette colors:',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: colorsList.length * 30,
                                      height: height * 0.17,
                                      child: Center(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: colorsList.length,
                                          itemBuilder: (context, index) =>
                                              PaletteColorItem(
                                                  color:
                                                      colorsList[index].color),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      : const SizedBox(),
                  SizedBox(height: height * 0.01),
                  Card(
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              backgroundColor: selectedColor,
                              radius: 20,
                            ),
                            Container(
                              height: height * 0.05,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black38),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('   HEX COLOR:  $selectedColor'),
                                  IconButton(
                                    onPressed: () {
                                      FlutterClipboard.copy('$selectedColor');
                                    },
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Divider(height: height * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                height: 35, width: 35, color: selectedColor),
                            Container(
                              height: height * 0.05,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black38),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '   RGB COLOR:  rgb(${selectedColor.red} , ${selectedColor.green} , ${selectedColor.blue})',
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      FlutterClipboard.copy(
                                          '( ${selectedColor.red} , ${selectedColor.green} , ${selectedColor.blue} )');
                                    },
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
