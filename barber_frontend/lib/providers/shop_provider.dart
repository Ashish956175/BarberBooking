import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

class ShopProvider with ChangeNotifier {
  List<Shop> _shops = [];
  List<Service> _services = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Shop> get shops => _shops;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> fetchShops({String? query}) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Fetching shops from API (Query: $query)...');
      String url = '/shops';
      if (query != null && query.isNotEmpty && query != 'All') {
        url += '?search=$query';
      }
      
      final response = await _apiService.get(url);
      // response is List
      _shops = (response as List).map((i) => Shop.fromJson(i)).toList();
      print('✅ Parsed ${_shops.length} shops');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching shops: $e');
      _isLoading = false;
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> fetchMyShops() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Fetching MY shops from API...');
      final response = await _apiService.get('/shops/my');
      _shops = (response as List).map((i) => Shop.fromJson(i)).toList();
      print('✅ Parsed ${_shops.length} specific shops');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching my shops: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchAnalytics(String shopId) async {
    try {
      final response = await _apiService.get('/analytics/$shopId');
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<List<dynamic>> fetchReviews(String shopId) async {
      try {
          final response = await _apiService.get('/reviews/$shopId');
          return response as List<dynamic>;
      } catch (e) {
          rethrow;
      }
  }

  Future<void> fetchServices(String shopId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/services/$shopId'); // Fixed: Removed backslash
       // response is List
      _services = (response as List).map((i) => Service.fromJson(i)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
       _isLoading = false;
       notifyListeners();
       print(e);
    }
  }

  Future<void> createShop(Map<String, dynamic> shopData) async {
      _isLoading = true;
      notifyListeners();
      try {
          await _apiService.post('/shops', shopData);
          await fetchShops(); // Refresh public list
          await fetchMyShops(); // Refresh owner list
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          rethrow;
      }
  }

  Future<void> updateShop(String shopId, Map<String, dynamic> shopData) async {
      _isLoading = true;
      notifyListeners();
      try {
          await _apiService.put('/shops/$shopId', shopData);
          await fetchShops();
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          rethrow;
      }
  }

  Future<String> uploadImage(String filePath) async {
      try {
          final res = await _apiService.uploadFile(filePath);
          return res['imageUrl'];
      } catch (e) {
          rethrow;
      }
  }

  Future<void> addGalleryImage(String shopId, String imageUrl) async {
      try {
          await _apiService.post('/shops/$shopId/gallery', {'imageUrl': imageUrl});
          await fetchShops(); // Refresh to see update
      } catch (e) {
          print(e);
          rethrow;
      }
  }

  Future<void> removeGalleryImage(String shopId, List<dynamic> currentImages, String imageToRemove) async {
      try {
          final newImages = List<String>.from(currentImages).where((img) => img != imageToRemove).toList();
          await updateShop(shopId, {'images': newImages});
      } catch (e) {
          rethrow;
      }
  }

  Future<void> addEmployee(String shopId, String name, String role, String imageUrl) async {
      try {
          await _apiService.post('/shops/$shopId/employees', {
              'name': name,
              'role': role,
              'imageUrl': imageUrl
          });
          await fetchShops();
          await fetchMyShops();
      } catch (e) {
           print(e);
           rethrow;
      }
  }

  Future<void> removeEmployee(String shopId, String employeeId) async {
      try {
          await _apiService.delete('/shops/$shopId/employees/$employeeId');
          await fetchShops();
          await fetchMyShops();
      } catch (e) {
           print(e);
           rethrow;
      }
  }

  Future<void> updateEmployee(String shopId, String employeeId, String name, String role, String imageUrl) async {
      try {
          await _apiService.put('/shops/$shopId/employees/$employeeId', {
              'name': name,
              'role': role,
              'imageUrl': imageUrl
          });
          await fetchMyShops(); // Refresh
      } catch (e) {
          rethrow;
      }
  }

  // --- Promotion Management ---
  Future<void> addPromotion(String shopId, Map<String, dynamic> promoData) async {
      try {
          await _apiService.post('/shops/$shopId/promotions', promoData);
          await fetchMyShops();
      } catch (e) {
          rethrow;
      }
  }

  Future<void> removePromotion(String shopId, String promoId) async {
      try {
          await _apiService.delete('/shops/$shopId/promotions/$promoId');
          await fetchMyShops();
      } catch (e) {
          rethrow;
      }
  }

  // --- Service Management ---
  Future<void> addService(String shopId, Map<String, dynamic> serviceData) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Add shopId to body if not present (controller expects it in body)
      serviceData['shopId'] = shopId;
      await _apiService.post('/services', serviceData);
      await fetchServices(shopId); // Refresh service list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateService(String serviceId, String shopId, Map<String, dynamic> serviceData) async {
      _isLoading = true;
      notifyListeners();
      try {
          await _apiService.put('/services/$serviceId', serviceData);
          await fetchServices(shopId);
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          rethrow;
      }
  }

  Future<void> deleteService(String serviceId, String shopId) async {
      _isLoading = true;
      notifyListeners();
      try {
          await _apiService.delete('/services/$serviceId');
          await fetchServices(shopId);
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          rethrow;
      }
  }
}
