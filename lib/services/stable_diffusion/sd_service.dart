import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:teia/models/stable_diffusion/prompt.dart';
import 'package:stability_sdk/stability_sdk.dart';

class StableDiffusionService {
  static const String engineId = 'stable-diffusion-512-v2-1';
  //stable-diffusion-v1
  //stable-diffusion-v1-5
  //stable-diffusion-512-v2-0
  //stable-diffusion-768-v2-0
  //stable-diffusion-512-v2-1
  //stable-diffusion-768-v2-1
  //stable-inpainting-v1-0
  //stable-inpainting-512-v2-0

  /// ERROR
  static List<dynamic> ERRORS = [];

  static Uri apiHost = Uri.https('api.stability.ai', 'v1alpha/generation/$engineId');
  //static Uri apiHost = Uri.https('lovely-clowns-carry-34-87-173-242.loca.lt', 'inator');

  static const String apiKey = 'sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa';

  static const int SAMPLES = 1;

  static final client = StabilityApiClient.init(apiKey);

  /// Replaces transparent pixels with white pixels and resizes the frame to 512x512.
  static Uint8List? normalizeMask(Uint8List? toBeMask, {bool resize = true, bool replaceTransparent = true}) {
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

  static void txt2img2(Function(String?) onImageGenerated) {
    log('TXT2IMG2');
    final request = RequestBuilder("an oil painting of a dog in the canvas, wearing knight armor, realistic painting by Leonardo da Vinci").setHeight(512).setWidth(512).setEngineType(EngineType.diffusion_512_v2_1).setSampleCount(1).build();
    client.generate(request).listen((answer) {
      onImageGenerated(answer.artifacts?.first.getImage());
    });
  }

  static Future<http.Response?> txt2img(String data) async {
    log('TXT2IMG');
    Uri uri = Uri.https('api.stability.ai', 'v1/generation/$engineId/text-to-image');
    print(uri);
    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $apiKey',
      },
      body: data,
    );
  }

  static Future<http.Response?> inpaint(String options, Uint8List initImage, Uint8List maskImage) async {
    log('INPAINT');
    var request = http.MultipartRequest("POST", apiHost);
    request.headers.addAll({
      'Accept': '*/*',
      'Authorization': apiKey,
    });
    request.fields['options'] = options;
    request.files.add(http.MultipartFile.fromBytes(
      'init_image',
      initImage,
      filename: 'init_image',
    ));
    request.files.add(http.MultipartFile.fromBytes(
      'mask_image',
      maskImage,
      filename: 'mask_image',
    ));
    return await http.Response.fromStream(await request.send());
  }

  static Future<Uint8List?> generate(double cfgScale, String clipGuidancePreset, int width, int height, int steps, List<Prompt> prompts, int samples, {Uint8List? initImage, Uint8List? maskImage}) async {
    List<Map<String, dynamic>> textPrompts = [];
    for (Prompt prompt in prompts) {
      textPrompts.add({
        'text': prompt.text,
        'weight': prompt.weight,
      });
    }
    try {
      http.Response? response;
      if (initImage != null && maskImage != null) {
        response = await inpaint(
          jsonEncode({
            'mask_source': 'MASK_IMAGE_WHITE',
            'cfg_scale': cfgScale,
            'clip_guidance_preset': clipGuidancePreset,
            'height': height,
            'width': width,
            'samples': samples,
            'steps': steps,
            'text_prompts': textPrompts,
          }),
          initImage,
          maskImage,
        );
      } else {
        response = await txt2img(
          jsonEncode({
            'cfg_scale': cfgScale,
            'clip_guidance_preset': clipGuidancePreset,
            'height': height,
            'width': width,
            'samples': samples,
            'steps': steps,
            'text_prompts': textPrompts,
          }),
        );
      }
      if (response == null) return null;
      if (response.statusCode != 200) return null;
      try {
        Map<String, dynamic> body = json.decode(response.body);
        ERRORS = body['errors'];
        log(ERRORS.toString());
        return null;
      } catch (e) {
        log(e.toString());
        log('Can\'t parse errors from request.');
      }
      return response.bodyBytes;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
