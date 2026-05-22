class OutfitStyle {
  final String description;
  final String garmentCategory; // tops | bottoms | one-pieces
  final String
  garmentImageUrl; // placeholder — replace with real garment images

  const OutfitStyle({
    required this.description,
    required this.garmentCategory,
    required this.garmentImageUrl,
  });
}

class OutfitConfig {
  // Job type → outfit mapping
  // garmentImageUrl: replace with real hosted garment images for FASHN API
  static const Map<String, OutfitStyle> _styles = {
    'Corporate / Finance': OutfitStyle(
      description:
          'Navy blue suit with white dress shirt and silk tie, professional business attire',
      garmentCategory: 'one-pieces',
      garmentImageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=512',
    ),
    'Tech / Startup': OutfitStyle(
      description:
          'Smart casual dark polo shirt with blazer, modern tech professional look',
      garmentCategory: 'tops',
      garmentImageUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=512',
    ),
    'Creative / Design': OutfitStyle(
      description:
          'Modern minimalist black turtleneck, artistic and stylish professional look',
      garmentCategory: 'tops',
      garmentImageUrl:
          'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=512',
    ),
    'Healthcare': OutfitStyle(
      description:
          'White medical lab coat over blue scrubs, professional healthcare attire',
      garmentCategory: 'one-pieces',
      garmentImageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=512',
    ),
    'Education': OutfitStyle(
      description:
          'Business casual button-up shirt with chinos, approachable and professional look',
      garmentCategory: 'tops',
      garmentImageUrl:
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=512',
    ),
    'Government': OutfitStyle(
      description:
          'Formal charcoal grey suit with white shirt and dark tie, authoritative professional attire',
      garmentCategory: 'one-pieces',
      garmentImageUrl:
          'https://images.unsplash.com/photo-1620912189865-1e8a33da4c4a?w=512',
    ),
  };

  static OutfitStyle forJobType(String jobType) =>
      _styles[jobType] ??
      const OutfitStyle(
        description:
            'Professional business attire suitable for a job interview',
        garmentCategory: 'one-pieces',
        garmentImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=512',
      );

  static List<String> get jobTypes => _styles.keys.toList();
}
