import 'package:teia/models/attachments/attachment.dart';

class TChoiceAttachment extends TAttachment {
  int pageId;
  TChoiceAttachment(text, this.pageId) : super(text);
}
