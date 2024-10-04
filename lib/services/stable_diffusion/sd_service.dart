import 'dart:developer';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class StableDiffusionService {
  static const String engineId = 'stable-diffusion-v1-6';
  static const String maskingEngineId = 'stable-diffusion-v1-6';
  static const String cloudflareAccountId = '3c3b1cd42e83b213fbc387bf1969c201';
  static const String cloudflareToken =
      'G442RWU8fdqa-C5qaBQz7QJ8Iaj75k9XyMct_Zvv';
  static const String promptStylerAppend = ', cinematic illustration';

  /// ERROR
  static List<dynamic> errors = [];

  //static Uri apiHost = Uri.https('api.stability.ai', 'v1/generation/$engineId');
  //static Uri apiHost = Uri.https('api.stability.ai', 'v2beta/stable-image/generate/core');
  static Uri apiHost = Uri.https('api.cloudflare.com',
      'client/v4/accounts/$cloudflareAccountId/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0');
  //static Uri apiHost = Uri.https('lovely-clowns-carry-34-87-173-242.loca.lt', 'inator');

  //static const String apiKey = 'sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa';
  static const String apiKey = cloudflareToken;

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

  static Future<http.Response?> txt2img(Map<String, dynamic> body) async {
    log('TXT2IMG -> $engineId');
    log(apiHost.toString());
    var headers = {
      "Authorization": "Bearer $apiKey",
      /*"Accept": "application/json",
      "Origin": "https://teia-tawny.vercel.app",
      "Access-Control-Allow-Origin": "https://teia-tawny.vercel.app",
      "Access-Control-Request-Method": "POST",
      "Access-Control-Request-Headers": "X-Custom-Header",*/
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,PUT,PATCH,POST,DELETE",
      "Access-Control-Allow-Headers":
          "Access-Control-Allow-Headers: X-Requested-With",
      "Access-Control-Allow-Credentials": "True",
      //"Content-Type": "multipart/form-data",
    };
    //FormData formData = FormData.fromMap(body);
    try {
      return await http.post(
        apiHost,
        /*options: Options(
          headers: headers,
        ),
        data: formData,*/
        headers: headers,
        body: jsonEncode(body),
      );
    } on DioException catch (e) {
      log(e.toString());
      log(e.error.toString());
      log(e.message.toString());
      log(e.response.toString());
      return null;
    }
  }

  static Future<http.Response?> inpaint(Map<String, dynamic> body,
      Uint8List initImage, Uint8List maskImage) async {
    log('INPAINT -> $maskingEngineId');
    var headers = {
      "Authorization": "Bearer $apiKey",
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };

    FormData formData = FormData.fromMap({
      ...{
        'init_image':
            MultipartFile.fromBytes(initImage, filename: 'init_image'),
        'mask_image':
            MultipartFile.fromBytes(maskImage, filename: 'mask_image'),
      },
      ...body,
    });

    try {
      return await http.post(
        Uri(),
        /*data: formData,
        options: Options(
          headers: headers,
        ),*/
      );
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<Uint8List?> generate(
      String prompt, String storyId, String chapterId,
      {Uint8List? initImage, Uint8List? maskImage}) async {
    try {
      http.Response? response;
      if (initImage != null && maskImage != null) {
        response = await inpaint(
          {
            'mask_source': 'MASK_IMAGE_WHITE',
            'samples': samples,
            'prompt': prompt + promptStylerAppend,
          },
          initImage,
          maskImage,
        );
      } else {
        response = await txt2img(
          {
            'prompt': prompt + promptStylerAppend,
            //'samples': samples,
          },
        );
      }
      if (response == null) return null;
      if (response.statusCode != 200) return null;
      Map<String, dynamic> data;
      try {
        //data = jsonDecode(response.toString());
        data = {
          "image": base64.encode(response.bodyBytes),
        };
      } catch (e) {
        log(e.toString());
        log('Can\'t parse Stable Diffusion response.');
        return null;
      }
      try {
        // Try to parse errors
        errors = data['errors'];
        log(errors.toString());
        return null;
      } catch (e) {
        log('Can\'t parse errors from request.');
      }
      return base64Decode(data['image'] as String);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
