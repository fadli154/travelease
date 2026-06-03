import '../../models/detection/landmark_food_model.dart';

class LandmarkFoodService {
  static const Map<String, Map<String, Map<String, String>>> _data = {
    'monas': {
      'en': {
        'name': 'Monas (National Monument)',
        'category': 'landmark',
        'origin': 'Jakarta, Indonesia',
        'description': 'The National Monument is a 132 m obelisk in the centre of Merdeka Square, Central Jakarta, symbolizing the fight for Indonesia\'s independence.',
      },
      'id': {
        'name': 'Monas (Monumen Nasional)',
        'category': 'landmark',
        'origin': 'Jakarta, Indonesia',
        'description': 'Monumen Nasional adalah tugu peringatan setinggi 132 meter yang didirikan untuk mengenang perlawanan dan perjuangan rakyat Indonesia dalam merebut kemerdekaan.',
      },
    },
    'borobudur': {
      'en': {
        'name': 'Borobudur Temple',
        'category': 'landmark',
        'origin': 'Magelang, Central Java',
        'description': 'Borobudur is a 9th-century Mahayana Buddhist temple in Magelang Regency, Central Java. It is the world\'s largest Buddhist temple.',
      },
      'id': {
        'name': 'Candi Borobudur',
        'category': 'landmark',
        'origin': 'Magelang, Jawa Tengah',
        'description': 'Borobudur adalah sebuah candi Buddha Mahayana abad ke-9 yang terletak di Kabupaten Magelang, Jawa Tengah, dan merupakan candi Buddha terbesar di dunia.',
      },
    },
    'prambanan': {
      'en': {
        'name': 'Prambanan Temple',
        'category': 'landmark',
        'origin': 'Sleman, Yogyakarta',
        'description': 'Prambanan is a 9th-century Hindu temple compound in the Special Region of Yogyakarta, dedicated to the Trimurti, the expression of God as the Creator, the Preserver and the Destroyer.',
      },
      'id': {
        'name': 'Candi Prambanan',
        'category': 'landmark',
        'origin': 'Sleman, Yogyakarta',
        'description': 'Prambanan adalah kompleks candi Hindu abad ke-9 yang terletak di Sleman, Yogyakarta, dipersembahkan untuk Trimurti, tiga dewa utama Hindu.',
      },
    },
    'rendang': {
      'en': {
        'name': 'Rendang',
        'category': 'food',
        'origin': 'West Sumatra',
        'description': 'Rendang is a Minangkabau spicy meat dish, prepared with beef slowly cooked in coconut milk and a paste of mixed spices until the liquid evaporates.',
      },
      'id': {
        'name': 'Rendang',
        'category': 'food',
        'origin': 'Sumatera Barat',
        'description': 'Rendang adalah masakan daging bercita rasa pedas yang menggunakan campuran berbagai bumbu dan rempah-rempah, dimasak perlahan dengan santan kelapa.',
      },
    },
    'gudeg': {
      'en': {
        'name': 'Gudeg',
        'category': 'food',
        'origin': 'Yogyakarta',
        'description': 'Gudeg is a traditional Javanese dish from Yogyakarta made from young unripe jackfruit boiled for several hours with palm sugar and coconut milk.',
      },
      'id': {
        'name': 'Gudeg',
        'category': 'food',
        'origin': 'Yogyakarta',
        'description': 'Gudeg adalah makanan khas Yogyakarta dan Jawa Tengah yang terbuat dari nangka muda yang dimasak selama beberapa jam dengan gula aren dan santan.',
      },
    },
    'sate': {
      'en': {
        'name': 'Sate (Satay)',
        'category': 'food',
        'origin': 'Java, Indonesia',
        'description': 'Satay is a Southeast Asian dish of seasoned, skewered and grilled meat, served with a flavorful sauce, most commonly peanut sauce.',
      },
      'id': {
        'name': 'Sate',
        'category': 'food',
        'origin': 'Jawa, Indonesia',
        'description': 'Sate adalah makanan yang terbuat dari potongan daging yang dipotong kecil-kecil dan ditusuk sedemikian rupa kemudian dipanggang menggunakan arang, disajikan dengan saus kacang atau kecap.',
      },
    },
  };

  static LandmarkFoodInfo getInfo(String label, String languageCode) {
    final cleanLabel = label.toLowerCase().trim();
    final locale = (languageCode == 'id') ? 'id' : 'en';

    final entry = _data[cleanLabel] ?? _data.entries.firstWhere(
      (e) => cleanLabel.contains(e.key) || e.key.contains(cleanLabel),
      orElse: () => MapEntry(cleanLabel, {
        'en': {
          'name': label,
          'category': 'landmark',
          'origin': 'Indonesia',
          'description': 'No description available for $label.',
        },
        'id': {
          'name': label,
          'category': 'landmark',
          'origin': 'Indonesia',
          'description': 'Deskripsi belum tersedia untuk $label.',
        }
      }),
    ).value;

    final localized = entry[locale] ?? entry['en']!;

    return LandmarkFoodInfo(
      name: localized['name'] ?? label,
      category: localized['category'] ?? 'landmark',
      origin: localized['origin'] ?? 'Indonesia',
      description: localized['description'] ?? '',
    );
  }
}
