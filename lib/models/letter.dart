class Letter extends Comparable<Letter> {
  final List<int> id;
  final String letter;

  Letter(this.id, this.letter);

  @override
  int compareTo(Letter other) {
    int i = 0;
    while (id[i] == other.id[i]) {
      i++;
      if (i >= id.length) return -1;
      if (i >= other.id.length) return 1;
    }
    return id[i] - other.id[i];
  }
}
