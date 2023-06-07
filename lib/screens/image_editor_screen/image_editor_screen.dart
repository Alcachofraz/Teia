import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'dart:ui' as ui;

import 'package:teia/models/stable_diffusion/generation.dart';
import 'package:teia/services/stable_diffusion/al_service.dart';
import 'package:teia/services/stable_diffusion/sd_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tap_icon.dart';
import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:teia/views/misc/tile.dart';

import 'package:dio/dio.dart';

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({Key? key}) : super(key: key);

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Generation? generation;

  late PainterController painterController;

  Uint8List? image;
  double eraserSize = Utils.minInpaintBrushThickness;

  bool generateBusy = false;

  String? base64;

  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    painterController = PainterController(
      settings: PainterSettings(
        freeStyle: const FreeStyleSettings(
          color: Colors.black,
          strokeWidth: 5,
          mode: FreeStyleMode.draw,
        ),
        shape: ShapeSettings(
          paint: shapePaint,
        ),
        scale: const ScaleSettings(
          enabled: true,
          minScale: 1,
          maxScale: 5,
        ),
      ),
    );
  }

  Future<Uint8List?> generate() async {
    if (generation != null) {
      Uint8List? mask;
      try {
        if (painterController.drawables.isNotEmpty) {
          final ui.Image renderedImage = await painterController.renderImage(const Size(512, 512));
          mask = StableDiffusionService.normalizeMask(await renderedImage.pngBytes, resize: false);
        } else {
          mask == null;
        }
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
            return SizedBox(
              width: screenSize.height * Utils.imageEditorHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenSize.height * Utils.imageEditorHeight,
                    child: Stack(
                      children: [
                        base64 != null
                            ? //Image.memory(image!, fit: BoxFit.fill)
                            CachedMemoryImage(
                                base64: base64,
                                uniqueKey: base64.toString(),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width,
                                child: const Center(
                                  child: Icon(
                                    Icons.hide_image_outlined,
                                    color: Colors.grey,
                                    size: 64.0,
                                  ),
                                ),
                              ),
                        FlutterPainter(
                          controller: painterController,
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
                            icon: const Icon(Icons.undo_rounded, color: Colors.black),
                            onTap: () {
                              if (painterController.canUndo) {
                                painterController.undo();
                              }
                            },
                          ),
                          const VerticalDivider(),
                          TapIcon(
                            icon: const Icon(Icons.redo_rounded, color: Colors.black),
                            onTap: () {
                              if (painterController.canRedo) {
                                painterController.redo();
                              }
                            },
                          ),
                          const VerticalDivider(),
                          const TapIcon(
                            icon: Icon(MdiIcons.eraser, color: Colors.black),
                            onTap: null,
                          ),
                          Expanded(
                            child: Slider(
                              min: 5.0,
                              max: 40.0,
                              value: eraserSize,
                              onChanged: (value) {
                                setState(() {
                                  eraserSize = value;
                                  painterController.freeStyleStrokeWidth = eraserSize;
                                });
                              },
                            ),
                          ),
                          const VerticalDivider(),
                          TapIcon(
                            icon: const Icon(MdiIcons.image),
                            onTap: () {
                              setState(() {
                                painterController.clearDrawables();
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
                            Uri uri = Uri.https('api.stability.ai', 'v1/generation/stable-diffusion-512-v2-1/text-to-image');

                            var body = {
                              "text_prompts": [
                                {"text": "A lighthouse on a cliff"}
                              ],
                              "cfg_scale": 7,
                              "clip_guidance_preset": "FAST_BLUE",
                              "height": 512,
                              "width": 512,
                              "samples": 1,
                              "steps": 30,
                            };
                            var headers = {
                              "Authorization": "Bearer sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa",
                              "Accept": "application/json",
                              "Content-Type": "application/json",
                            };
                            final dio = Dio();
                            try {
                              var response = await dio.post(
                                'https://api.stability.ai/v1/generation/stable-diffusion-v1-5/text-to-image',
                                data: body,
                                options: Options(
                                  headers: headers,
                                ),
                              );
                              print(response.data);
                            } on DioException catch (e) {
                              print(e);
                            }

                            /*http.Request request = http.Request('POST', uri);
                            request.body = body;
                            request.headers['content-type'] = 'application/json';
                            request.headers['accept'] = 'application/json';
                            request.headers['Authorization'] = 'Bearer sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa';
                            var res = (await request.send()).;
                            print(res.body);
                            setState(() {
                              generateBusy = false;
                            });*/
                            /*Uint8List? aux = await generate();
                            if (aux == null && mounted) {
                              snackBar(context, 'Image generation is not working at the moment.');
                            }*/
                            /*StableDiffusionService.txt2img2(
                              (image) => setState(
                                () {
                                  painterController.clearDrawables();
                                  //image = aux;
                                  generateBusy = false;
                                  base64 = image;
                                },
                              ),
                            );*/
                            /*setState(() {
                              painterController.clearDrawables();
                              image = aux;
                              generateBusy = false;
                            });*/
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
