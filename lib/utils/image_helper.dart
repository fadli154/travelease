/// Demo-friendly images without Firebase Storage.
class ImageHelper {
  ImageHelper._();

  /// Resolves destination image: Firestore URL, or stable Picsum placeholder.
  static String destinationDisplayUrl(
    String imageUrl, {
    String seed = 'travelease',
  }) {
    final trimmed = imageUrl.trim();
    if (trimmed.isNotEmpty) return trimmed;
    final safeSeed = seed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').isEmpty
        ? 'travel'
        : seed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'https://picsum.photos/seed/$safeSeed/800/500';
  }

  /// Avatar URL: Firestore photoUrl, or ui-avatars.com from name.
  static String userAvatarUrl({
    required String name,
    String photoUrl = '',
  }) {
    final trimmed = photoUrl.trim();
    if (trimmed.isNotEmpty) return trimmed;
    final displayName = name.trim().isEmpty ? 'Traveler' : name.trim();
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=0D9488&color=fff&size=256';
  }
}
