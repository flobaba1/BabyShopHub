class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromRow(Map<String, String?> row) {
    return Category(id: row['id'] ?? '', name: row['name'] ?? '');
  }
}
