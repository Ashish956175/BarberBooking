import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/api_service.dart';

class AppointmentProvider with ChangeNotifier {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  List<Appointment> _myAppointments = [];
  List<Appointment> _shopAppointments = [];

  bool get isLoading => _isLoading;
  List<Appointment> get myAppointments => _myAppointments;
  List<Appointment> get shopAppointments => _shopAppointments;

  Future<void> bookAppointment(String shopId, String serviceId, DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/appointments', {
        'shopId': shopId,
        'serviceId': serviceId,
        'date': date.toIso8601String(),
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> bookAppointmentWithPayment(
    String shopId,
    String serviceId,
    DateTime date,
    String paymentMethod,
    double paymentAmount,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('/appointments', {
        'shopId': shopId,
        'serviceId': serviceId,
        'date': date.toIso8601String(),
        'paymentMethod': paymentMethod,
        'paymentAmount': paymentAmount,
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMyAppointments() async {
      _isLoading = true;
      notifyListeners();
      try {
          final response = await _apiService.get('/appointments/my');
          _myAppointments = (response as List).map((i) => Appointment.fromJson(i)).toList();
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          print(e);
      }
  }

  Future<void> fetchShopAppointments(String shopId) async {
      _isLoading = true;
      notifyListeners();
      try {
          final response = await _apiService.get('/appointments/shop/$shopId');
          _shopAppointments = (response as List).map((i) => Appointment.fromJson(i)).toList();
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          print(e);
          rethrow;
      }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
      _isLoading = true;
      notifyListeners();
      try {
          await _apiService.put('/appointments/$appointmentId', {'status': status});
          
          // Update local list
          final index = _shopAppointments.indexWhere((element) => element.id == appointmentId);
          if (index != -1) {
              _shopAppointments[index] = Appointment(
                  id: _shopAppointments[index].id,
                  shopId: _shopAppointments[index].shopId,
                  shopName: _shopAppointments[index].shopName,
                  shopAddress: _shopAppointments[index].shopAddress,
                  serviceName: _shopAppointments[index].serviceName,
                  price: _shopAppointments[index].price,
                  date: _shopAppointments[index].date,
                  status: status,
                  paymentMethod: _shopAppointments[index].paymentMethod,
                  paymentAmount: _shopAppointments[index].paymentAmount,
                  transactionTime: _shopAppointments[index].transactionTime,
                  transactionId: _shopAppointments[index].transactionId,
              );
          }
          
           // Also update myAppointments if present (for customer view updates)
          final myIndex = _myAppointments.indexWhere((element) => element.id == appointmentId);
          if (myIndex != -1) {
             _myAppointments[myIndex] = Appointment(
                  id: _myAppointments[myIndex].id,
                  shopId: _myAppointments[myIndex].shopId,
                  shopName: _myAppointments[myIndex].shopName,
                  shopAddress: _myAppointments[myIndex].shopAddress,
                  serviceName: _myAppointments[myIndex].serviceName,
                  price: _myAppointments[myIndex].price,
                  date: _myAppointments[myIndex].date,
                  status: status
              );
          }
          
          _isLoading = false;
          notifyListeners();
      } catch (e) {
          _isLoading = false;
          notifyListeners();
          rethrow;
      }
  }

  Future<void> submitReview(String shopId, int rating, String comment) async {
    _isLoading = true;
    notifyListeners();
    try {
        await _apiService.post('/reviews', {
            'shopId': shopId,
            'rating': rating,
            'comment': comment
        });
        _isLoading = false;
        notifyListeners();
    } catch (e) {
        _isLoading = false;
        notifyListeners();
        rethrow;
    }
  }
}
