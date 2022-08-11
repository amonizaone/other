extension ExtendedString on String {
  String removeWhitespace() {
    // Remove all white space.
    return replaceAll(RegExp(r"\s+"), "");
  }

  String removeWhitespacePrefix([String prefix = '']) {
    // Remove all white space.
    return replaceAll(RegExp(r"\s+"), prefix);
  }
}

extension UtilListExtension on List {
  groupBy(String key) {
    try {
      List<Map<String, dynamic>> result = [];
      List<String> keys = [];

      forEach((f) => keys.add(f[key]));

      for (var k in [...keys.toSet()]) {
        List data = [...where((e) => e[key] == k)];
        result.add({k: data});
      }

      return result;
    } catch (e) {
      //printCatchNReport(e, s);
      return this;
    }
  }

  //sumByKey(key) {
  //  return map((e) => e['key'] as int).fold<int>(0, (a, b) => a + b);
  //}
}
