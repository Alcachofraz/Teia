import 'package:teia/models/stable_diffusion/generation.dart';
import 'package:teia/models/stable_diffusion/prompt.dart';

class AccessLayerService {
  /// Stream image generation arguments for group [groupId].
  static Stream<Generation> groupImageGenerationArguments(String groupId) {
    return Stream<Generation>.value(
      Generation(
        8.0,
        'NONE',
        512,
        512,
        30,
        1,
        [
          Prompt(
            1,
            'a xenomorph playing a grand piano inside a library',
          ),
        ],
      ),
    );
  }
}
