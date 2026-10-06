class Shop {
  final String id;
  final String name;
  final String address;
  final String? description;
  final List<String>? images;
  final Map<String, dynamic>? openingHours;
  final double? rating;
  final int? reviewCount;
  final List<Map<String, dynamic>>? employees;
  final List<Map<String, dynamic>>? promotions;
  final String status;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    this.images,
    this.openingHours,
    this.rating,
    this.reviewCount,
    this.employees,
    this.promotions,
    this.status = 'approved', // Default for legacy/local
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      openingHours: json['openingHours'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['numReviews'] as int?,
      employees: json['employees'] != null 
          ? List<Map<String, dynamic>>.from(json['employees'].map((e) => Map<String, dynamic>.from(e)))
          : [],
      promotions: json['promotions'] != null 
          ? List<Map<String, dynamic>>.from(json['promotions'].map((e) => Map<String, dynamic>.from(e)))
          : [],
      status: json['status'] ?? 'approved', // Default to approved so existing shops don't break
    );
  }
}
