import 'package:collection/collection.dart';

void main() {
  print('id:');
  print(generateId([10, 20, 40], [10, 20, 40, 10]).toString());
}

const int intMaxValue = 2147483647;
const int boundary = 10;

List<int> generateId(List<int>? p, List<int>? q) {
  if (p != null) {
    List<int> ret = List.from(p);
    if (ret.last + boundary > intMaxValue) {
      ret.removeLast();
      ret.last += boundary;
    } else {
      ret.last += boundary;
    }
    if (q != null && const ListEquality().equals(ret, q)) {
      return List.from(p)..add(boundary);
    }
    return ret;
  } else if (p == null && q != null) {
    List<int> ret = List.from(q);
    if (ret.last - boundary <= 0) {
      ret.last = 0;
      return ret..add(boundary);
    } else {
      ret.last -= boundary;
      return ret;
    }
  } else {
    // All null
    return [boundary]; // Create first id
  }
}
