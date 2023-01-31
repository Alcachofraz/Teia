import 'package:teia/models/page.dart';

class Chapter {
  int id;
  String title;
  List<Page> pages;
  Chapter(this.id, this.title, this.pages);
}
