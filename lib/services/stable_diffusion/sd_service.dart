import 'dart:developer';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:teia/models/stable_diffusion/prompt.dart';

class StableDiffusionService {
  static const String engineId = 'stable-diffusion-xl-beta-v2-2-2';
  static const String maskingEngineId = 'stable-inpainting-512-v2-0';

  static const String promptStyler = '''8k, detailed, sharp, vivid, soft glow, artstation, 
  (Midjourney style) hyperrealism, highly detailed, insanely detailed, intricate, cinematic 
  lighting, depth of field, god ray, glow, glare, cinematic, dynamic lighting, behance, 
  sharp focus, concept art, spike painting, illustration, concept art, key visual''';

  static const String negativePromptStyler = '''bad, ugly, overexposed, low contrast, 
  cut off, tiling, watermark, blurry, deformed, weird colors, mutated color, muted color, 
  photo realistic, fused, less detail, lowres, out of frame, worst quality, low quality, 
  normal quality, displaced object''';

  /*
  [
    {
        "description": "Real-ESRGAN_x2plus upscaler model",
        "id": "esrgan-v1-x2plus",
        "name": "Real-ESRGAN x2",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion v1.4",
        "id": "stable-diffusion-v1",
        "name": "Stable Diffusion v1.4",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion v1.5",
        "id": "stable-diffusion-v1-5",
        "name": "Stable Diffusion v1.5",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion v2.0",
        "id": "stable-diffusion-512-v2-0",
        "name": "Stable Diffusion v2.0",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion 768 v2.0",
        "id": "stable-diffusion-768-v2-0",
        "name": "Stable Diffusion v2.0-768",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion Depth v2.0",
        "id": "stable-diffusion-depth-v2-0",
        "name": "Stable Diffusion v2.0-depth",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion v2.1",
        "id": "stable-diffusion-512-v2-1",
        "name": "Stable Diffusion v2.1",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion 768 v2.1",
        "id": "stable-diffusion-768-v2-1",
        "name": "Stable Diffusion v2.1-768",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Diffusion XL Beta v2.2.2",
        "id": "stable-diffusion-xl-beta-v2-2-2",
        "name": "Stable Diffusion v2.2.2-XL Beta",
        "type": "PICTURE"
    },
    {
        "description": "Stable Diffusion x4 Latent Upscaler",
        "id": "stable-diffusion-x4-latent-upscaler",
        "name": "Stable Diffusion x4 Latent Upscaler",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Inpainting v1.0",
        "id": "stable-inpainting-v1-0",
        "name": "Stable Inpainting v1.0",
        "type": "PICTURE"
    },
    {
        "description": "Stability-AI Stable Inpainting v2.0",
        "id": "stable-inpainting-512-v2-0",
        "name": "Stable Inpainting v2.0",
        "type": "PICTURE"
    }
  ]
  */

  /// ERROR
  static List<dynamic> ERRORS = [];

  static Uri apiHost = Uri.https('api.stability.ai', 'v1alpha/generation/$engineId');
  //static Uri apiHost = Uri.https('lovely-clowns-carry-34-87-173-242.loca.lt', 'inator');

  static const String apiKey = 'sk-DY0hd8PcPKrQCRtiGL6bzRObUbOmBjgGHuQJudHTGHdjcCZa';

  static const int SAMPLES = 1;

  static final dio = Dio();

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

  static Future<Response<dynamic>?> txt2img(Map<String, dynamic> body) async {
    log('TXT2IMG');
    var headers = {
      "Authorization": "Bearer $apiKey",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    try {
      return await dio.post(
        'https://api.stability.ai/v1/generation/$engineId/text-to-image',
        data: body,
        options: Options(
          headers: headers,
        ),
      );
    } on DioException catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Response<dynamic>?> inpaint(Map<String, dynamic> body, Uint8List initImage, Uint8List maskImage) async {
    log('INPAINT');
    var headers = {
      "Authorization": "Bearer $apiKey",
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };

    FormData formData = FormData.fromMap({
      ...{
        'init_image': MultipartFile.fromBytes(initImage, filename: 'init_image'),
        'mask_image': MultipartFile.fromBytes(maskImage, filename: 'mask_image'),
      },
      ...body,
    });

    try {
      return await dio.post(
        'https://api.stability.ai/v1/generation/$maskingEngineId/image-to-image/masking',
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
    } on DioException catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Uint8List?> generate(double cfgScale, String clipGuidancePreset, int width, int height, int steps, List<Prompt> prompts, int samples, {Uint8List? initImage, Uint8List? maskImage}) async {
    List<Map<String, dynamic>> textPrompts = [];
    for (Prompt prompt in prompts) {
      textPrompts.add({
        'text': '${prompt.text}, $promptStyler',
        'weight': prompt.weight,
      });
    }
    textPrompts.add({
      'text': negativePromptStyler,
      'weight': -1,
    });
    try {
      Response<dynamic>? response;
      if (initImage != null && maskImage != null) {
        response = await inpaint(
          {
            'mask_source': 'MASK_IMAGE_WHITE',
            'cfg_scale': cfgScale,
            'clip_guidance_preset': clipGuidancePreset,
            'samples': samples,
            'steps': steps,
            'text_prompts': textPrompts,
          },
          initImage,
          maskImage,
        );
      } else {
        response = await txt2img(
          {
            'cfg_scale': cfgScale,
            'clip_guidance_preset': clipGuidancePreset,
            'height': height,
            'width': width,
            'samples': samples,
            'steps': steps,
            'text_prompts': textPrompts,
          },
        );
      }
      if (response == null) return null;
      if (response.statusCode != 200) return null;
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.toString());
      } catch (e) {
        log(e.toString());
        log('Can\'t parse Stable Diffusion response.');
        return null;
      }
      try {
        // Try to parse errors
        ERRORS = data['errors'];
        log(ERRORS.toString());
        return null;
      } catch (e) {
        log('Can\'t parse errors from request.');
      }
      Map<String, dynamic> firstImage = data['artifacts'][0];
      var imageBytes = base64Decode(firstImage['base64'] as String);
      return imageBytes;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
