import 'dart:developer';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class StableDiffusionService {
  static const String engineId = 'stable-diffusion-v1-6';
  static const String maskingEngineId = 'stable-diffusion-v1-6';
  static const String promptStylerAppend = ', cinematic illustration';

  /// ERROR
  static List<dynamic> errors = [];

  //static Uri apiHost = Uri.https('api.stability.ai', 'v1/generation/$engineId');
  //static Uri apiHost = Uri.https('api.stability.ai', 'v2beta/stable-image/generate/core');
  static Uri apiHost = Uri.https('teia-generate.vercel.app');
  //static Uri apiHost = Uri.https('lovely-clowns-carry-34-87-173-242.loca.lt', 'inator');

  //static const String apiKey = 'sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa';
  static const String apiKey = '';

  static const int samples = 1;

  static final Dio dio = Dio();

  /// Replaces transparent pixels with white pixels and resizes the frame to 512x512.
  static Uint8List? normalizeMask(Uint8List? toBeMask,
      {bool resize = true, bool replaceTransparent = true}) {
    if (toBeMask == null) return null;
    img.Image? image = img.decodeImage(toBeMask);
    if (image == null) return null;
    if (resize) {
      image = img.copyResize(image, width: 512, height: 512);
    }
    if (replaceTransparent) {
      Uint8List pixels = image.getBytes();
      for (int i = 0, len = pixels.length; i < len; i += 4) {
        if (pixels[i + 3] == 0) {
          pixels[i] = 0;
          pixels[i + 1] = 0;
          pixels[i + 2] = 0;
          pixels[i + 3] = 255;
        } else {
          pixels[i] = 255;
          pixels[i + 1] = 255;
          pixels[i + 2] = 255;
          pixels[i + 3] = 255;
        }
      }
    }
    return Uint8List.fromList(img.encodePng(image));
  }

  static Future<Response<dynamic>?> txt2img(Map<String, dynamic> body) async {
    log('TXT2IMG -> $engineId');
    log(apiHost.toString());
    var headers = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,PUT,PATCH,POST,DELETE",
      "Access-Control-Allow-Headers":
          "Access-Control-Allow-Headers: X-Requested-With",
      "Access-Control-Allow-Credentials": "True",
    };
    try {
      return await dio.post(
        apiHost.toString(),
        options: Options(
          headers: headers,
        ),
        data: body,
      );
    } on DioException catch (e) {
      log(e.toString());
      log(e.error.toString());
      log(e.message.toString());
      log(e.response.toString());
      getx.Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('${e.message}\n${e.response}\n${e.error}'),
          actions: [
            TextButton(
              onPressed: () {
                getx.Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return null;
    }
  }

  static Future<Uint8List?> generate(
      String prompt, String storyId, String chapterId,
      {Uint8List? initImage, Uint8List? maskImage}) async {
    try {
      Response<dynamic>? response;

      response = await txt2img(
        {
          'prompt': prompt + promptStylerAppend,
          //'samples': samples,
        },
      );

      if (response == null) return null;
      if (response.statusCode != 200) {
        getx.Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: Text('[${response.statusCode}] ${response.data}'),
            actions: [
              TextButton(
                onPressed: () {
                  getx.Get.back();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return null;
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.toString());
      } catch (e) {
        log(e.toString());
        log('Can\'t parse Stable Diffusion response.');
        getx.Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  getx.Get.back();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return null;
      }
      return base64Decode(data['image'] as String);
    } catch (e) {
      log(e.toString());
      getx.Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('[exception] ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                getx.Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return null;
    }
  }
}
