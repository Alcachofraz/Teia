import 'package:flutter_quill/flutter_quill.dart' hide Text;

class PageOperation {
  final String uid;
  final Delta delta;

  PageOperation(this.uid, this.delta);

  factory PageOperation.fromMap(Map<String, dynamic> map) {
    return PageOperation(
      map['uid'],
      Delta.fromJson(List.from(map['delta'])),
    );
  }

  Map<String, dynamic> toMap() => {'uid': uid, 'delta': delta.toJson()};
}
