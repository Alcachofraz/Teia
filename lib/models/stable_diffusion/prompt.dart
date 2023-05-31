class Prompt {
  double weight;
  String text;

  Prompt(this.weight, this.text);

  Map<String, Object> toMap() {
    return Map<String, Object>.from({
      'text': 'a lighthouse on a cliff, by greg rutkowski',
      'weight': 1,
    });
  }
}
