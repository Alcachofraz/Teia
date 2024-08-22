import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_painter/image_painter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:teia/models/stable_diffusion/generation.dart';
import 'package:teia/services/stable_diffusion/al_service.dart';
import 'package:teia/services/stable_diffusion/sd_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tap_icon.dart';
import 'package:teia/views/misc/tile.dart';

class ImageEditorScreen<Uint8List> extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Generation? generation;

  late ImagePainterController painterController;

  Uint8List? image;
  double eraserSize = Utils.minInpaintBrushThickness;

  bool generateBusy = false;

  String? base64;

  Paint shapePaint = Paint()
    ..strokeWidth = 20
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    painterController = ImagePainterController(
      color: Colors.black,
      strokeWidth: 20,
      mode: PaintMode.freeStyle,
    );
  }

  Future<Uint8List?> generate() async {
    if (generation != null) {
      Uint8List? mask;
      try {
        Uint8List? byteArray = await painterController.exportImage();
        mask = StableDiffusionService.normalizeMask(
          byteArray,
          resize: true,
        );
      } catch (e) {
        mask = null;
      }
      return await StableDiffusionService.generate(
        generation!.cfgScale,
        generation!.clipGuidancePreset,
        generation!.width,
        generation!.height,
        generation!.steps,
        generation!.prompts,
        StableDiffusionService.SAMPLES,
        initImage: image,
        maskImage: mask,
      );
    } else {
      return null;
    }
  }

  void useImage() {
    Get.back(result: image);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ScreenWrapper(
      //resizeToAvoidBottomInset: false,
      body: StreamBuilder<Generation>(
        stream: AccessLayerService.groupImageGenerationArguments(''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loadingRotate();
          } else {
            generation = snapshot.data;
            return StatefulBuilder(builder: (context, setState) {
              return SizedBox(
                width: screenSize.height * Utils.imageEditorHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenSize.height * Utils.imageEditorHeight,
                      height: screenSize.height * Utils.imageEditorHeight,
                      child: Stack(
                        children: [
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
                          Positioned.fill(
                            child: ImagePainter.memory(
                              image!,
                              controller: painterController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tile(
                      padding: EdgeInsets.zero,
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            const VerticalDivider(),
                            TapIcon(
                              icon: const Icon(Icons.undo_rounded,
                                  color: Colors.black),
                              onTap: () {
                                painterController.undo();
                              },
                            ),
                            const VerticalDivider(),
                            TapIcon(
                              icon: const Icon(Icons.redo_rounded,
                                  color: Colors.black),
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
                                    painterController
                                        .setStrokeWidth(eraserSize);
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
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                      child: TextFormField(
                        initialValue: generation!.prompts[0].text,
                        decoration: const InputDecoration(
                          hintText: 'Prompt',
                        ),
                        onChanged: (text) {
                          generation!.prompts[0].text = text;
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

                              var imaggeBytes = await generate();

                              setState(() {
                                image = imaggeBytes;
                                painterController.clear();
                                generateBusy = false;
                              });
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
                                    ? loadingDots(
                                        color: Colors.white, size: 16.0)
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
                      onTap: useImage,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: SizedBox(
                                height: 24,
                                child: Text(
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
            });
          }
        },
      ),
    );
  }
}
