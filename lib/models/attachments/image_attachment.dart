import 'package:teia/models/attachments/attachment.dart';

class TImageAttachment extends TAttachment {
  String imageUrl;
  TImageAttachment(text, this.imageUrl) : super(text);
}
