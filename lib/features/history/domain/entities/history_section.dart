class HistorySection<T> {
  const HistorySection({
    this.items = const [],
    this.errorMessage,
  });

  final List<T> items;
  final String? errorMessage;

  bool get isEmpty => items.isEmpty;
  bool get hasError => errorMessage != null;
  int get count => items.length;
}
