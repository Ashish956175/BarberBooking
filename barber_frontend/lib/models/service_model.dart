class Service {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int duration;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
    );
  }
}
