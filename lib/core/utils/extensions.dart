import 'package:flutter/widgets.dart';

extension StringListParsingX on String {
  List<String> splitToEntries() {
    return split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

extension BuildContextX on BuildContext {
  void unfocusCurrent() => FocusScope.of(this).unfocus();
}
