class Appointment {
  final String id;
  final String shopId;
  final String shopName;
  final String shopAddress;
  final String serviceName;
  final double price;
  final DateTime date;
  final String status;
  final String? paymentMethod;
  final double? paymentAmount;
  final DateTime? transactionTime;
  final String? transactionId;

  Appointment({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopAddress,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.status,
    this.paymentMethod,
    this.paymentAmount,
    this.transactionTime,
    this.transactionId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Handling populated fields
    final shop = json['shop'];
    final service = json['service'];
    final payment = json['payment'];
    
    String sName = 'Unknown Shop';
    String sAddress = '';
    String sId = '';
    String servName = 'Unknown Service';
    double servPrice = 0.0;

    if (shop is Map) {
        sName = shop['name'] ?? 'Unknown Shop';
        sAddress = shop['address'] ?? '';
        sId = shop['_id'] ?? '';
    } else if (shop is String) {
        sId = shop;
    }
    
    if (service is Map) {
        servName = service['name'] ?? 'Unknown Service';
        servPrice = (service['price'] as num?)?.toDouble() ?? 0.0;
    }

    return Appointment(
      id: json['_id'],
      shopId: sId,
      shopName: sName,
      shopAddress: sAddress,
      serviceName: servName,
      price: servPrice,
      date: DateTime.parse(json['date']),
      status: json['status'],
      paymentMethod: payment != null ? payment['method'] : null,
      paymentAmount: payment != null ? (payment['amount'] as num?)?.toDouble() : null,
      transactionTime: payment != null && payment['transactionTime'] != null 
          ? DateTime.parse(payment['transactionTime']) 
          : null,
      transactionId: payment != null ? payment['transactionId'] : null,
    );
  }
}
