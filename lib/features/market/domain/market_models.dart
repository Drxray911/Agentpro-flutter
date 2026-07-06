/// Domain models for Market Centre (spec §3.11, §4.1 advertisements).
library market_models;

enum AdStatus { draft, pendingReview, feeDue, active, expiring, expired, rejected, flagged }
enum AdCategory { vehicles, realEstate, phones, electronics, fashion, business, services, agriculture }

extension AdCategoryX on AdCategory {
  String get label => switch (this) {
        AdCategory.vehicles => 'Vehicles',
        AdCategory.realEstate => 'Real Estate',
        AdCategory.phones => 'Phones',
        AdCategory.electronics => 'Electronics',
        AdCategory.fashion => 'Fashion',
        AdCategory.business => 'Business',
        AdCategory.services => 'Services',
        AdCategory.agriculture => 'Agriculture',
      };

  String get icon => switch (this) {
        AdCategory.vehicles => '🚗',
        AdCategory.realEstate => '🏠',
        AdCategory.phones => '📱',
        AdCategory.electronics => '🖥',
        AdCategory.fashion => '👗',
        AdCategory.business => '💼',
        AdCategory.services => '🛠',
        AdCategory.agriculture => '🌿',
      };
}

/// Maps to the `advertisements` table (spec §4.1).
class AdListing {
  final String id;
  final String businessId;
  final String postedBy;
  final String sellerName;
  final String sellerPhone;
  final bool sellerVerified;
  final String title;
  final String description;
  final AdCategory category;
  final double price;
  final bool negotiable;
  final String location;
  final List<String> images; // emoji placeholders in demo; real = Firebase URLs
  final AdStatus status;
  final double listingFee;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final bool featured;
  final int viewsCount;
  final double sellerRating;

  const AdListing({
    required this.id,
    required this.businessId,
    required this.postedBy,
    required this.sellerName,
    required this.sellerPhone,
    this.sellerVerified = false,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.negotiable = false,
    required this.location,
    this.images = const [],
    required this.status,
    required this.listingFee,
    this.publishedAt,
    this.expiresAt,
    this.featured = false,
    this.viewsCount = 0,
    this.sellerRating = 0,
  });

  bool get isActive => status == AdStatus.active || status == AdStatus.expiring;
  String get priceLabel => 'GH₵ ${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
  int get daysLeft => expiresAt != null ? expiresAt!.difference(DateTime.now()).inDays.clamp(0, 999) : 0;

  factory AdListing.fromJson(Map<String, dynamic> j) => AdListing(
        id: j['id'] as String,
        businessId: j['business_id'] as String,
        postedBy: j['posted_by'] as String,
        sellerName: j['seller_name'] as String? ?? '',
        sellerPhone: j['seller_phone'] as String? ?? '',
        sellerVerified: j['seller_verified'] as bool? ?? false,
        title: j['title'] as String,
        description: j['description'] as String? ?? '',
        category: AdCategory.values.firstWhere((c) => c.name == j['category'], orElse: () => AdCategory.business),
        price: (j['price'] as num).toDouble(),
        negotiable: j['negotiable'] as bool? ?? false,
        location: j['location'] as String? ?? '',
        images: (j['images'] as List?)?.cast<String>() ?? [],
        status: AdStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => AdStatus.active),
        listingFee: (j['listing_fee'] as num? ?? 0).toDouble(),
        publishedAt: j['published_at'] != null ? DateTime.parse(j['published_at'] as String) : null,
        expiresAt: j['expires_at'] != null ? DateTime.parse(j['expires_at'] as String) : null,
        featured: j['featured'] as bool? ?? false,
        viewsCount: j['views_count'] as int? ?? 0,
        sellerRating: (j['seller_rating'] as num? ?? 0).toDouble(),
      );

  static List<AdListing> demoList() => [
        AdListing(id: '1', businessId: 'b1', postedBy: 'u1', sellerName: 'Kwabena Darko', sellerPhone: '0244111222', sellerVerified: true, title: 'Toyota Camry 2019 — Excellent Condition', description: 'Full options, leather seats, reverse camera, 78,000km. Accident-free. Serious buyers only.', category: AdCategory.vehicles, price: 85000, negotiable: true, location: 'Accra, East Legon', images: ['🚗'], status: AdStatus.active, listingFee: 850, publishedAt: DateTime.now().subtract(const Duration(days: 5)), expiresAt: DateTime.now().add(const Duration(days: 25)), featured: true, viewsCount: 142, sellerRating: 4.8),
        AdListing(id: '2', businessId: 'b1', postedBy: 'u2', sellerName: 'Tech Palace Ghana', sellerPhone: '0551999888', sellerVerified: true, title: 'iPhone 15 Pro Max 256GB Natural Titanium', description: 'Brand new, sealed box with Apple warranty. Genuine Apple product with receipt.', category: AdCategory.phones, price: 9500, negotiable: false, location: 'Accra, Osu', images: ['📱'], status: AdStatus.active, listingFee: 95, publishedAt: DateTime.now().subtract(const Duration(days: 2)), expiresAt: DateTime.now().add(const Duration(days: 28)), viewsCount: 89, sellerRating: 4.9),
        AdListing(id: '3', businessId: 'b1', postedBy: 'u3', sellerName: 'GoldCoast Properties', sellerPhone: '0277555444', sellerVerified: true, title: 'Modern Office Space — Accra CBD', description: '250sqm air-conditioned office in prime Accra CBD. Parking available. Ideal for corporate use.', category: AdCategory.realEstate, price: 3500, negotiable: true, location: 'Accra CBD', images: ['🏢'], status: AdStatus.active, listingFee: 35, publishedAt: DateTime.now().subtract(const Duration(days: 10)), expiresAt: DateTime.now().add(const Duration(days: 20)), viewsCount: 67, sellerRating: 4.6),
        AdListing(id: '4', businessId: 'b1', postedBy: 'u4', sellerName: 'ElectroHub Ghana', sellerPhone: '0264333222', sellerVerified: false, title: 'Samsung 55" QLED 4K Smart TV', description: 'Brand new Samsung 55" QLED. Full smart TV with Netflix, YouTube. 2-year warranty.', category: AdCategory.electronics, price: 6200, negotiable: false, location: 'Kumasi, Kejetia', images: ['📺'], status: AdStatus.active, listingFee: 62, publishedAt: DateTime.now().subtract(const Duration(days: 8)), expiresAt: DateTime.now().add(const Duration(days: 22)), viewsCount: 45, sellerRating: 4.2),
        AdListing(id: '5', businessId: 'b1', postedBy: 'u5', sellerName: 'ProTax Ghana', sellerPhone: '0244777666', sellerVerified: true, title: 'Tax Consultation & Filing Service', description: 'Professional tax filing for individuals and businesses. GRA-registered tax consultant.', category: AdCategory.services, price: 200, negotiable: true, location: 'Accra (Remote available)', images: ['📊'], status: AdStatus.active, listingFee: 2, publishedAt: DateTime.now().subtract(const Duration(days: 15)), expiresAt: DateTime.now().add(const Duration(days: 15)), viewsCount: 23, sellerRating: 4.7),
        AdListing(id: '6', businessId: 'b1', postedBy: 'u1', sellerName: 'Kwabena Darko', sellerPhone: '0244111222', sellerVerified: true, title: 'Honda Civic 2021 — Low Mileage', description: 'Well maintained, 42,000km. One owner. Full service history. Available for test drive.', category: AdCategory.vehicles, price: 72000, negotiable: true, location: 'Accra, Tema', images: ['🚙'], status: AdStatus.expiring, listingFee: 720, publishedAt: DateTime.now().subtract(const Duration(days: 23)), expiresAt: DateTime.now().add(const Duration(days: 7)), viewsCount: 98, sellerRating: 4.8),
      ];

  static List<AdListing> myAds() => [
        AdListing(id: '7', businessId: 'b1', postedBy: 'me', sellerName: 'Kwame Asante', sellerPhone: '0244000000', title: 'MacBook Air M2 — Like New', description: 'Used for 3 months. Comes with original charger and box.', category: AdCategory.electronics, price: 8500, location: 'Accra', images: ['💻'], status: AdStatus.active, listingFee: 85, publishedAt: DateTime.now().subtract(const Duration(days: 4)), expiresAt: DateTime.now().add(const Duration(days: 26)), viewsCount: 34, sellerRating: 4.5),
        AdListing(id: '8', businessId: 'b1', postedBy: 'me', sellerName: 'Kwame Asante', sellerPhone: '0244000000', title: 'Kente Fabric — Premium Quality', description: 'Hand-woven Kente from Bonwire. Various patterns available. Minimum 6 yards.', category: AdCategory.fashion, price: 450, location: 'Accra', images: ['👘'], status: AdStatus.feeDue, listingFee: 4.50, sellerRating: 0),
        AdListing(id: '9', businessId: 'b1', postedBy: 'me', sellerName: 'Kwame Asante', sellerPhone: '0244000000', title: 'Office Furniture Set', description: 'Complete office setup: 4 desks, 4 chairs, bookshelf. Good condition.', category: AdCategory.business, price: 2800, location: 'Accra', images: ['🪑'], status: AdStatus.expired, listingFee: 28, viewsCount: 12, sellerRating: 0),
      ];
}
