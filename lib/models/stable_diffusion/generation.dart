import 'package:teia/models/stable_diffusion/prompt.dart';

class Generation {
  final double cfgScale;
  final String clipGuidancePreset;
  final int width;
  final int height;
  final int steps;
  final List<Prompt> prompts;

  Generation(this.cfgScale, this.clipGuidancePreset, this.width, this.height, this.steps, this.prompts);
}
