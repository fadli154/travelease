class LandmarkFoodInfo {
  final String name;
  final String category; // 'landmark' or 'food'
  final String origin; // location or origin
  final String description;

  const LandmarkFoodInfo({
    required this.name,
    required this.category,
    required this.origin,
    required this.description,
  });
}
