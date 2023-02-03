import 'package:teia/models/attachments/attachment.dart';
import 'package:teia/models/attachments/simple_text_attachment.dart';

class TPage {
  int id;
  List<TAttachment> attachments;
  TPage(this.id, this.attachments);

  factory TPage.create(int id) {
    return TPage(
      0,
      [
        TSimpleTextAttachment('Once upon a time...'),
      ],
    );
  }
}
