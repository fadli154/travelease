import '../models/destination_model.dart';

/// Client-side grouping only — does not change Firestore schema.
abstract final class DestinationSections {
  static List<DestinationModel> featured(List<DestinationModel> all) {
    if (all.isEmpty) return [];
    final sorted = List<DestinationModel>.from(all)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  static List<DestinationModel> popular(List<DestinationModel> all) {
    if (all.isEmpty) return [];
    final featuredIds = featured(all).map((d) => d.id).toSet();
    final rest = all.where((d) => !featuredIds.contains(d.id)).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    if (rest.isNotEmpty) return rest;
    return List<DestinationModel>.from(all)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<String> categories(List<DestinationModel> all) {
    final set = <String>{};
    for (final d in all) {
      if (d.category.trim().isNotEmpty) set.add(d.category.trim());
    }
    final list = set.toList()..sort();
    return list;
  }
}
