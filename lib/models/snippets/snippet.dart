enum SnippetType { text, image, choice }

class Snippet {
  final String text;
  final SnippetType type;
  final Map<String, dynamic> attributes;

  Snippet(
    this.text,
    this.type,
    this.attributes,
  );

  Map<String, dynamic> toMap() => {
        'text': text,
        'type': type.index,
        'attributes': attributes,
      };

  factory Snippet.fromMap(Map<String, dynamic> map) {
    return Snippet(
      map['text'],
      SnippetType.values[map['type']],
      Map<String, dynamic>.from(map['attributes'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    return text == text && type == type && attributes == attributes;
  }

  @override
  int get hashCode => text.hashCode + type.hashCode;

  @override
  String toString() {
    return '{text: $text, type: $type, attributes: $attributes}';
  }
}
