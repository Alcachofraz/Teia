import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:teia/services/stable_diffusion/sd_service.dart';
import 'package:teia/services/storage_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tap_icon.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:painter/painter.dart';

class ImageEditorScreen<Uint8List> extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late String initialText;
  String text = '';
  late PainterController painterController;

  Uint8List? image;
  double eraserSize = Utils.minInpaintBrushThickness;

  bool generateBusy = false;
  bool returning = false;

  String? base64;

  Paint shapePaint = Paint()
    ..strokeWidth = 20
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  late String storyId;
  late String chapterId;

  @override
  void initState() {
    storyId = Get.parameters['story_id']!;
    chapterId = Get.parameters['chapter_id']!;
    super.initState();
    initialText = Get.parameters['text'] ?? '';
    text = initialText;
    painterController = PainterController();
    painterController.drawColor = Colors.black;
    painterController.backgroundColor = Colors.transparent;
    painterController.thickness = 20;
  }

  Future<Uint8List?> generate() async {
    if (text.isNotEmpty) {
      /*Uint8List? mask;
      try {
        Uint8List? byteArray = await painterController.finish().toPNG();
        mask = StableDiffusionService.normalizeMask(
          byteArray,
          resize: true,
        );
      } catch (e) {
        mask = null;
      }*/
      return await StableDiffusionService.generate(
        text,
        storyId,
        chapterId,
        initImage: image,
        //maskImage: mask,
      );
    } else {
      return null;
    }
  }

  Future<void> useImage() async {
    setState(() {
      returning = true;
    });
    if (image != null) {
      String url = await StorageService.to.uploadImage(
        storyId,
        chapterId,
        image!,
      );
      Get.back(result: url);
    } else {
      Get.back(result: null);
    }
    setState(() {
      returning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final double size = screenSize.height * Utils.imageEditorHeight;
    return ScreenWrapper(
      body: StatefulBuilder(builder: (context, setState) {
        return SizedBox(
          width: size,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size,
                width: size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Painter(painterController),
                    ),
                    image != null
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: MemoryImage(image!),
                              ),
                            ),
                          )
                        : const SizedBox.expand(
                            child: Center(
                              child: Icon(
                                Icons.hide_image_outlined,
                                color: Colors.grey,
                                size: 64.0,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              /* Tile(
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      const VerticalDivider(),
                      TapIcon(
                        icon:
                            const Icon(Icons.undo_rounded, color: Colors.black),
                        onTap: () {
                          painterController.undo();
                        },
                      ),
                      const VerticalDivider(),
                      TapIcon(
                        icon:
                            const Icon(Icons.redo_rounded, color: Colors.black),
                        onTap: () {
                          //painterController.undo();
                        },
                      ),
                      const VerticalDivider(),
                      TapIcon(
                        icon: Icon(MdiIcons.eraser, color: Colors.black),
                        onTap: null,
                      ),
                      Expanded(
                        child: Slider(
                          min: Utils.minInpaintBrushThickness,
                          max: Utils.maxInpaintBrushThickness,
                          value: eraserSize,
                          onChanged: (value) {
                            setState(() {
                              eraserSize = value;
                              painterController.thickness = eraserSize;
                            });
                          },
                        ),
                      ),
                      const VerticalDivider(),
                      TapIcon(
                        icon: Icon(MdiIcons.image),
                        onTap: () {
                          setState(() {
                            painterController.clear();
                          });
                        },
                      ),
                      const VerticalDivider(),
                    ],
                  ),
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: TextFormField(
                  initialValue: initialText,
                  decoration: const InputDecoration(
                    hintText: 'Prompt',
                  ),
                  onChanged: (currentText) {
                    text = currentText;
                  },
                ),
              ),
              Tile(
                padding: EdgeInsets.zero,
                color: Colors.black,
                onTap: generateBusy
                    ? null
                    : () async {
                        setState(() {
                          generateBusy = true;
                        });
                        var imageBytes = await generate();
                        if (imageBytes != null) {
                          setState(() {
                            image = imageBytes;
                            painterController.clear();
                            generateBusy = false;
                          });
                        } else {
                          Get.snackbar(
                            "Error",
                            "The generator failed. Please try again later.",
                          );
                          setState(() {
                            generateBusy = false;
                          });
                        }
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 24,
                          child: generateBusy
                              ? loadingDots(color: Colors.white, size: 16.0)
                              : const Text(
                                  "Generate",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Tile(
                padding: EdgeInsets.zero,
                color: Colors.black,
                onTap: returning ? null : useImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 24,
                          child: returning
                              ? loadingDots(color: Colors.white, size: 16.0)
                              : const Text(
                                  "Use image",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
