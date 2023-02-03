import 'package:teia/models/attachments/chapter_graph.dart';
import 'package:teia/models/page.dart';

class TChapter {
  int id;
  String title;
  TChapterGraph graph;
  List<TPage> pages;

  TChapter(this.id, this.title, this.pages, this.graph);

  bool addPage(int start) {
    int newId = graph.numberOfPages() + 1;
    pages.add(TPage.create(newId));
    return graph.addConnection(start, newId);
  }

  factory TChapter.create(int id, String title) {
    return TChapter(
      id,
      title,
      [TPage.create(1)],
      TChapterGraph({1: []}),
    );
  }
}
